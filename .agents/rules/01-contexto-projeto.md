# Contexto do Projeto: Igreja em Belo Horizonte (Portal de Vida Comum)

## 1. Visão Geral
Este não é um site institucional ou um sistema de gestão de uma "empresa religiosa". É uma intranet orgânica para facilitar a "vida comum" dos irmãos (Atos 2). O foco está em relacionamentos ("juntas e ligamentos") e não em membresia fria.

## 2. Nomenclatura Estrita
Os agentes DEVEM usar os seguintes termos nas interfaces e variáveis:
- NÃO use "Membros"; use "Discípulos" ou "Irmãos".
- NÃO use "Igreja" no sentido de instituição/prédio; use "A Igreja na cidade" ou "O Corpo".
- NÃO use "Líder/Chefe"; use "Presbitério", "Diaconato" ou "Discipulador".
- Os grupos que se reúnem nas casas são chamados de "Grupos Caseiros" ou "Oikos".

## 3. Lógica de Relacionamentos (Core Business)
A estrutura de dados central não é o indivíduo isolado, mas a quem ele está ligado. A tabela `profiles` possui auto-relacionamento (`discipler_id`) para montar a "Árvore de Discipulado". Todas as features desenvolvidas devem respeitar a privacidade e a prestação de contas baseada nesses vínculos.
