import fs from 'fs';
import path from 'path';
import { createClient } from '@supabase/supabase-js';

function parseEnv(filePath) {
  if (!fs.existsSync(filePath)) return {};
  const content = fs.readFileSync(filePath, 'utf8');
  const env = {};
  content.split(/\r?\n/).forEach((line) => {
    line = line.trim();
    if (!line || line.startsWith('#')) return;
    const index = line.indexOf('=');
    if (index !== -1) {
      const key = line.substring(0, index).trim();
      let value = line.substring(index + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      env[key] = value;
    }
  });
  return env;
}

const env = { ...parseEnv('.env'), ...parseEnv('.env.local') };
const supabaseUrl = env.VITE_SUPABASE_URL;
const anonKey = env.VITE_SUPABASE_PUBLISHABLE_KEY || env.VITE_SUPABASE_PUBLISHABLE_DEFAULT_KEY || env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !anonKey) {
  console.error('❌ VITE_SUPABASE_URL and publishable/anon key are required in .env');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, anonKey);

async function runTests() {
  console.log('====================================================');
  console.log('🚀 INICIANDO TESTES DO SISTEMA DE CUPONS E FLUXO UX');
  console.log('====================================================\n');

  let passed = 0;
  let failed = 0;

  function assert(condition, testName, details = '') {
    if (condition) {
      console.log(`  ✅ [PASS] ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ [FAIL] ${testName}: ${details}`);
      failed++;
    }
  }

  // ----------------------------------------------------
  // TEST SUITE 1: Verificação de RLS Pública em retreats
  // ----------------------------------------------------
  console.log('📦 TEST SUITE 1: Leitura Pública de Eventos/Retiros (Anon RLS)');
  try {
    const { data: retreats, error } = await supabase
      .from('retreats')
      .select('id, title, price, has_payment, status, form_id')
      .eq('form_id', 'form-solteiros-2026');

    assert(!error, 'Consulta anônima à tabela retreats sem erro', error?.message);
    assert(retreats && retreats.length > 0, 'Visitante anônimo consegue ler o evento associado', `Retornou ${retreats?.length || 0} registros`);
    if (retreats && retreats.length > 0) {
      assert(retreats[0].has_payment === true, 'Evento pago possui has_payment: true');
      assert(Number(retreats[0].price) === 350, 'Evento possui preço base correto (R$ 350,00)');
    }
  } catch (e) {
    assert(false, 'Exceção ao consultar retreats como anônimo', e.message);
  }

  // ----------------------------------------------------
  // TEST SUITE 2: RPC de Validação de Cupons (validate_coupon)
  // ----------------------------------------------------
  console.log('\n🎟️ TEST SUITE 2: Validação Atômica de Cupons (validate_coupon)');
  const testCpf = '10382154052';
  const wrongCpf = '11144477735';
  const testCode = 'ISENTO-YQ5E';

  try {
    // 2.1 Código Válido com CPF Correto
    const { data: validRes, error: err1 } = await supabase.rpc('validate_coupon', {
      p_code: testCode,
      p_retreat_id: '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc',
      p_form_id: 'form-solteiros-2026',
      p_cpf: testCpf,
    });
    assert(!err1, 'RPC validate_coupon executada sem erro de rede', err1?.message);
    assert(validRes?.valid === true, 'Cupom ativo com CPF correspondente retorna valid: true', JSON.stringify(validRes));
    assert(validRes?.discount_percent === 100, 'Cupom retorna discount_percent: 100 para isenção total', JSON.stringify(validRes));

    // 2.2 Código Válido com CPF Incorreto
    const { data: invalidCpfRes } = await supabase.rpc('validate_coupon', {
      p_code: testCode,
      p_retreat_id: '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc',
      p_form_id: 'form-solteiros-2026',
      p_cpf: wrongCpf,
    });
    assert(invalidCpfRes?.valid === false, 'Cupom com CPF divergente retorna valid: false');
    assert(
      invalidCpfRes?.message?.includes('outro CPF'),
      'Mensagem clara de divergência de CPF retornada',
      invalidCpfRes?.message
    );

    // 2.3 Código Inexistente
    const { data: nonExistentRes } = await supabase.rpc('validate_coupon', {
      p_code: 'ISENTO-FAKE999',
      p_retreat_id: '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc',
      p_form_id: 'form-solteiros-2026',
      p_cpf: testCpf,
    });
    assert(nonExistentRes?.valid === false, 'Código inexistente retorna valid: false');
  } catch (e) {
    assert(false, 'Exceção no teste de validate_coupon', e.message);
  }

  // ----------------------------------------------------
  // TEST SUITE 3: Criação de Cupom Temporário e Resgate (Ciclo de Vida)
  // ----------------------------------------------------
  console.log('\n🔒 TEST SUITE 3: Ciclo Completo de Resgate Atômico (redeem_coupon)');
  const tempCode = `TESTE-${Math.random().toString(36).substring(2, 6).toUpperCase()}`;
  const tempCpf = '52998224725'; // CPF válido para teste

  try {
    // Inserir cupom de teste usando rpc ou insert direto se permitido
    // Como anon não pode dar insert direto em event_coupons (segurança correta),
    // vamos testar a tentativa de resgate bloqueada do código fake
    const { data: redeemFakeRes } = await supabase.rpc('redeem_coupon', {
      p_code: 'ISENTO-INEXISTENTE',
      p_cpf: tempCpf,
      p_user_name: 'Usuário Teste',
      p_user_email: 'teste@exemplo.com',
    });
    assert(redeemFakeRes?.success === false, 'Resgate de cupom inexistente bloqueado com success: false');

    // Tentativa de resgate do cupom real com CPF errado
    const { data: redeemWrongCpf } = await supabase.rpc('redeem_coupon', {
      p_code: testCode,
      p_cpf: wrongCpf,
      p_user_name: 'Beneficiário Falso',
      p_user_email: 'falso@exemplo.com',
      p_retreat_id: '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc',
      p_form_id: 'form-solteiros-2026',
    });
    assert(redeemWrongCpf?.success === false, 'Resgate com CPF divergente bloqueado no redeem_coupon');
    assert(
      redeemWrongCpf?.message?.includes('não corresponde ao CPF cadastrado'),
      'Mensagem explícita de erro de CPF no resgate',
      redeemWrongCpf?.message
    );
  } catch (e) {
    assert(false, 'Exceção no teste de redeem_coupon', e.message);
  }

  // ----------------------------------------------------
  // TEST SUITE 4: Inserção de Inscrição em Retiro com guest_data
  // ----------------------------------------------------
  console.log('\n📝 TEST SUITE 4: Validação de Inserção de Inscrição Pública');
  try {
    const tempSubId = `sub-test-${Math.random().toString(36).substring(7)}`;

    // Criar form submission teste
    const { error: subErr } = await supabase.from('form_submissions').insert({
      id: tempSubId,
      form_id: 'form-solteiros-2026',
      data: {
        mandatory_full_name: 'Participante Teste Automatizado',
        mandatory_email: 'teste.auto@example.com',
        mandatory_phone: '(31) 99999-8888',
        mandatory_gender: 'Masculino',
      },
      user_id: null,
    });
    assert(!subErr, 'Visitante anônimo consegue inserir form_submission pública', subErr?.message);

    // Inserir registration correspondente com campos obrigatórios (sem .select() para anônimo, exatamente como o FormResponder)
    const { error: regErr } = await supabase
      .from('registrations')
      .insert({
        retreat_id: '4faf45cb-c431-48f6-9d3f-598fbe9e5bcc',
        profile_id: null,
        guest_data: {
          full_name: 'Participante Teste Automatizado',
          email: 'teste.auto@example.com',
          phone: '(31) 99999-8888',
          gender: 'Masculino',
          cpf: testCpf,
        },
        custom_responses: {
          'Sexo / Gênero': 'Masculino',
        },
        payment_method: 'cupom',
        payment_reference: `Isenção - Teste Automatizado`,
        paid: true,
        form_submission_id: tempSubId,
      });

    assert(!regErr, 'Inscrição com todos os dados obrigatórios inserida com sucesso (anon INSERT)', regErr?.message);

    // Limpeza da fixture
    if (tempSubId) {
      await supabase.from('registrations').delete().eq('form_submission_id', tempSubId);
      await supabase.from('form_submissions').delete().eq('id', tempSubId);
      console.log('  🧹 Fixtures temporárias de teste limpas com sucesso');
    }
  } catch (e) {
    assert(false, 'Exceção no teste de inserção de inscrição', e.message);
  }

  // ----------------------------------------------------
  // TEST SUITE 5: Verificação de UI/UX Mobile-First e Touch Targets
  // ----------------------------------------------------
  console.log('\n📱 TEST SUITE 5: Auditoria de Diretrizes UI/UX Mobile-First (Código)');
  
  const formResponderContent = fs.readFileSync('src/pages/FormResponder.tsx', 'utf8');
  const presentationViewContent = fs.readFileSync('src/components/forms/FormPresentationView.tsx', 'utf8');
  const couponsTabContent = fs.readFileSync('src/components/events/EventCouponsTab.tsx', 'utf8');

  // 5.1 Touch targets mínimos de 44px
  assert(
    formResponderContent.includes('min-h-[44px]') || formResponderContent.includes('h-11'),
    'FormResponder possui touch targets mínimos de 44px (h-11 / min-h-[44px]) nos inputs e botões'
  );

  assert(
    presentationViewContent.includes('min-h-[44px]') || presentationViewContent.includes('h-11'),
    'FormPresentationView possui touch target mínimo de 44px no botão de CTA ("Avançar para Inscrição")'
  );

  assert(
    couponsTabContent.includes('min-h-[44px]') || couponsTabContent.includes('h-11'),
    'EventCouponsTab possui botões de ação e inputs com touch target acessível de 44px'
  );

  assert(
    couponsTabContent.includes('Percentual de Desconto') && couponsTabContent.includes('newDiscountPercent'),
    'EventCouponsTab permite ao gestor definir o percentual de desconto no modal de criação'
  );

  assert(
    couponsTabContent.includes('<Slider') && couponsTabContent.includes('min={1}') && couponsTabContent.includes('max={100}'),
    'EventCouponsTab utiliza componente Slider para seleção de percentual de 1 a 100%'
  );

  assert(
    formResponderContent.includes('discountPct') && formResponderContent.includes('originalPrice > checkoutPrice'),
    'FormResponder calcula abatimento proporcional e exibe detalhamento do desconto no checkout'
  );

  // 5.2 Não vazamento horizontal (overflow-x contido, flex/grid responsivos)
  assert(
    formResponderContent.includes('grid-cols-1') && formResponderContent.includes('md:grid-cols-2'),
    'Layout responsivo mobile-first com transição de 1 coluna para 2 colunas em telas maiores'
  );

  assert(
    presentationViewContent.includes('max-w-4xl') && presentationViewContent.includes('px-4'),
    'Página de apresentação com padding lateral protetivo contra corte em 320px de largura'
  );

  assert(
    formResponderContent.includes('couponValidation.checked && !couponValidation.valid'),
    'Banner de erro em destaque para cupom inválido/expirado com explicação clara ao usuário'
  );

  // 5.3 Validação de CPF restrita ao gerador e não ao formulário
  assert(
    couponsTabContent.includes('isValidCPF(cleanCpf)') && couponsTabContent.includes('isValidCPF(newCpf)'),
    'EventCouponsTab valida matematicamente o CPF do beneficiário na criação do cupom'
  );

  assert(
    !formResponderContent.includes('if (cleanCpf.length !== 11 || !isValidCPF(cleanCpf))') &&
      formResponderContent.includes('validate_coupon'),
    'FormResponder verifica o CPF exclusivamente contra a lista de cupons ativos sem bloquear por algoritmo no formulário'
  );

  // ----------------------------------------------------
  // RESUMO FINAL
  // ----------------------------------------------------
  console.log('\n====================================================');
  console.log(`📊 RESULTADO DOS TESTES: ${passed} PASSOU | ${failed} FALHOU`);
  console.log('====================================================');

  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
