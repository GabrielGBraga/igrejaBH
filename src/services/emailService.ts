import supabase from "@/lib/supabase"

export interface SendEmailOptions {
  to: string | string[]
  subject: string
  html?: string
  text?: string
  from?: string
  reply_to?: string | string[]
}

export interface SendEmailResponse {
  success: boolean
  id?: string
  error?: string
}

/**
 * Envia um e-mail transacional via Supabase Edge Function com fallback para rota Vercel API.
 */
export async function sendEmail(options: SendEmailOptions): Promise<SendEmailResponse> {
  const { to, subject, html, text, from, reply_to } = options

  try {
    // 1. Tentar disparo via Supabase Edge Function (send-email)
    const { data, error } = await supabase.functions.invoke("send-email", {
      body: { to, subject, html, text, from, reply_to },
    })

    if (!error && data?.success) {
      return { success: true, id: data?.data?.id }
    }

    if (error) {
      console.warn("Aviso ao invocar Edge Function send-email, tentando fallback:", error)
    }
  } catch (err) {
    console.warn("Falha na Edge Function, acionando fallback local/Vercel:", err)
  }

  // 2. Fallback para rota serverless do Vercel (/api/send-email)
  try {
    const res = await fetch("/api/send-email", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ to, subject, html, text, from, reply_to }),
    })

    const result = await res.json()
    if (res.ok && result.success) {
      return { success: true, id: result?.data?.id }
    }

    return {
      success: false,
      error: result?.error || "Erro desconhecido ao processar e-mail via API.",
    }
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : String(err)
    console.error("Erro no envio de e-mail:", errorMsg)
    return { success: false, error: errorMsg }
  }
}

// ============================================================================
// Templates e Disparadores Específicos
// ============================================================================

const BASE_CONTAINER_STYLE = `
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  max-width: 580px;
  margin: 0 auto;
  background-color: #ffffff;
  border-radius: 8px;
  border: 1px solid #e5e7eb;
  overflow: hidden;
`

const HEADER_STYLE = `
  background-color: #18181b;
  color: #fafafa;
  padding: 24px;
  text-align: center;
`

const BODY_STYLE = `
  padding: 28px 24px;
  color: #27272a;
  line-height: 1.6;
  font-size: 15px;
`

const FOOTER_STYLE = `
  padding: 20px 24px;
  background-color: #f4f4f5;
  color: #71717a;
  font-size: 13px;
  text-align: center;
  border-top: 1px solid #e4e4e7;
`

const BUTTON_STYLE = `
  display: inline-block;
  background-color: #18181b;
  color: #ffffff !important;
  text-decoration: none;
  font-weight: 600;
  padding: 12px 24px;
  border-radius: 6px;
  margin-top: 16px;
`

/**
 * Notificação para cooperadores sobre novo contato da Landing Page
 */
export async function sendContactNotificationEmail(params: {
  fullName: string
  phone: string
  region: string
  message?: string
  recipientEmail?: string
}) {
  const { fullName, phone, region, message, recipientEmail = "onboarding@resend.dev" } = params

  const html = `
    <div style="${BASE_CONTAINER_STYLE}">
      <div style="${HEADER_STYLE}">
        <h2 style="margin: 0; font-size: 20px; font-weight: 600;">Novo Contato — Quer Conhecer a Comunhão</h2>
        <p style="margin: 6px 0 0; font-size: 14px; opacity: 0.85;">Igreja em Belo Horizonte</p>
      </div>
      <div style="${BODY_STYLE}">
        <p>Graça e paz! Uma pessoa manifestou desejo de conhecer os grupos caseiros e caminhar conosco em Belo Horizonte:</p>
        <div style="background-color: #f9fafb; border-left: 4px solid #18181b; padding: 14px; margin: 18px 0; border-radius: 4px;">
          <p style="margin: 4px 0;"><strong>Nome:</strong> ${fullName}</p>
          <p style="margin: 4px 0;"><strong>WhatsApp:</strong> <a href="https://wa.me/55${phone.replace(/\D/g, "")}">${phone}</a></p>
          <p style="margin: 4px 0;"><strong>Região de BH:</strong> ${region}</p>
          ${message ? `<p style="margin: 8px 0 4px;"><strong>Mensagem:</strong><br/>${message}</p>` : ""}
        </div>
        <p style="margin-bottom: 0;">Favor acolher o irmão ou visitante com presteza e direcioná-lo ao grupo caseiro mais próximo.</p>
      </div>
      <div style="${FOOTER_STYLE}">
        <p style="margin: 0;">Igreja em Belo Horizonte • Caminhando no propósito eterno em comunhão de lares</p>
      </div>
    </div>
  `

  return sendEmail({
    to: recipientEmail,
    subject: `[Acolhimento] Novo contato de ${fullName} (${region})`,
    html,
  })
}

/**
 * Notificação de confirmação de inscrição para eventos e retiros
 */
export async function sendRegistrationConfirmationEmail(params: {
  participantName: string
  eventTitle: string
  eventDate?: string
  eventLocation?: string
  whatsappGroupUrl?: string
  recipientEmail: string
}) {
  const { participantName, eventTitle, eventDate, eventLocation, whatsappGroupUrl, recipientEmail } = params

  const html = `
    <div style="${BASE_CONTAINER_STYLE}">
      <div style="${HEADER_STYLE}">
        <h2 style="margin: 0; font-size: 20px; font-weight: 600;">Inscrição Confirmada!</h2>
        <p style="margin: 6px 0 0; font-size: 14px; opacity: 0.85;">${eventTitle}</p>
      </div>
      <div style="${BODY_STYLE}">
        <p>Graça e paz, <strong>${participantName}</strong>!</p>
        <p>Sua inscrição para o <strong>${eventTitle}</strong> está confirmada. Cremos que será um tempo precioso de edificação mútua e fortalecimento no Senhor.</p>
        
        <div style="background-color: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px; padding: 16px; margin: 20px 0;">
          <h4 style="margin: 0 0 10px; font-size: 15px; color: #111827;">Detalhes do Encontro:</h4>
          ${eventDate ? `<p style="margin: 4px 0;">📅 <strong>Data:</strong> ${eventDate}</p>` : ""}
          ${eventLocation ? `<p style="margin: 4px 0;">📍 <strong>Local:</strong> ${eventLocation}</p>` : ""}
        </div>

        ${
          whatsappGroupUrl
            ? `
          <div style="text-align: center; margin: 24px 0;">
            <p style="margin-bottom: 12px; font-weight: 500;">Entre no grupo de avisos e comunicações oficiais do evento:</p>
            <a href="${whatsappGroupUrl}" target="_blank" style="${BUTTON_STYLE}">
              Acessar Grupo no WhatsApp
            </a>
          </div>
        `
            : ""
        }

        <p style="margin-top: 24px; font-size: 14px; color: #4b5563;">
          Se precisar de alguma orientação adicional, procure os irmãos responsáveis pela organização.
        </p>
      </div>
      <div style="${FOOTER_STYLE}">
        <p style="margin: 0;">Igreja em Belo Horizonte • Uma família de muitos filhos semelhantes a Jesus</p>
      </div>
    </div>
  `

  return sendEmail({
    to: recipientEmail,
    subject: `Confirmação de Inscrição: ${eventTitle}`,
    html,
  })
}

/**
 * Notificação de confirmação na Lista de Espera
 */
export async function sendWaitlistConfirmationEmail(params: {
  participantName: string
  eventTitle: string
  recipientEmail: string
}) {
  const { participantName, eventTitle, recipientEmail } = params

  const html = `
    <div style="${BASE_CONTAINER_STYLE}">
      <div style="${HEADER_STYLE}">
        <h2 style="margin: 0; font-size: 20px; font-weight: 600;">Lista de Espera Registrada</h2>
        <p style="margin: 6px 0 0; font-size: 14px; opacity: 0.85;">${eventTitle}</p>
      </div>
      <div style="${BODY_STYLE}">
        <p>Graça e paz, <strong>${participantName}</strong>!</p>
        <p>Recebemos o seu cadastro na lista de espera para o <strong>${eventTitle}</strong>.</p>
        <p>Como a capacidade do local foi atingida, organizamos a fila por ordem de inscrição. Caso ocorra alguma desistência ou liberação de vagas adicionais, entraremos em contato imediatamente pelo seu WhatsApp ou e-mail.</p>
        <p style="margin-top: 20px; color: #4b5563; font-size: 14px;">
          Agradecemos pelo seu carinho e desejo de comunhão.
        </p>
      </div>
      <div style="${FOOTER_STYLE}">
        <p style="margin: 0;">Igreja em Belo Horizonte • Uma família de muitos filhos semelhantes a Jesus</p>
      </div>
    </div>
  `

  return sendEmail({
    to: recipientEmail,
    subject: `Lista de Espera: ${eventTitle}`,
    html,
  })
}

/**
 * Notificação de vaga liberada na Lista de Espera (Chamada)
 */
export async function sendWaitlistCallEmail(params: {
  participantName: string
  eventTitle: string
  registrationUrl: string
  recipientEmail: string
}) {
  const { participantName, eventTitle, registrationUrl, recipientEmail } = params

  const html = `
    <div style="${BASE_CONTAINER_STYLE}">
      <div style="${HEADER_STYLE}">
        <h2 style="margin: 0; font-size: 20px; font-weight: 600;">Uma vaga foi liberada para você!</h2>
        <p style="margin: 6px 0 0; font-size: 14px; opacity: 0.85;">${eventTitle}</p>
      </div>
      <div style="${BODY_STYLE}">
        <p>Graça e paz, <strong>${participantName}</strong>!</p>
        <p>Uma vaga acabou de ser aberta para você no <strong>${eventTitle}</strong>.</p>
        <p>Para garantir seu lugar, por favor acesse o link exclusivo abaixo e conclua sua inscrição o quanto antes:</p>
        
        <div style="text-align: center; margin: 24px 0;">
          <a href="${registrationUrl}" target="_blank" style="${BUTTON_STYLE}">
            Completar Minha Inscrição Agora
          </a>
        </div>

        <p style="margin-top: 24px; font-size: 13px; color: #6b7280;">
          Caso não vá participar, por favor avise a organização para que o próximo irmão da fila possa ser chamado.
        </p>
      </div>
      <div style="${FOOTER_STYLE}">
        <p style="margin: 0;">Igreja em Belo Horizonte • Uma família de muitos filhos semelhantes a Jesus</p>
      </div>
    </div>
  `

  return sendEmail({
    to: recipientEmail,
    subject: `Vaga Liberada: ${eventTitle}`,
    html,
  })
}
