/**
 * Gerenciamento de estado do Modo Restrito de Grupo Caseiro.
 * Quando ativo, restringe a navegação do usuário exclusivamente à página
 * de gestão do seu grupo (/meu-grupo), bloqueando o acesso ao restante do portal.
 */

const RESTRICTED_MODE_STORAGE_KEY = "igreja_restricted_group_mode"

export function isRestrictedGroupMode(): boolean {
  if (typeof window === "undefined") return false
  try {
    return (
      sessionStorage.getItem(RESTRICTED_MODE_STORAGE_KEY) === "true" ||
      localStorage.getItem(RESTRICTED_MODE_STORAGE_KEY) === "true"
    )
  } catch {
    return false
  }
}

export function enableRestrictedGroupMode(): void {
  if (typeof window === "undefined") return
  try {
    sessionStorage.setItem(RESTRICTED_MODE_STORAGE_KEY, "true")
    localStorage.setItem(RESTRICTED_MODE_STORAGE_KEY, "true")
  } catch (e) {
    console.warn("Não foi possível salvar estado do modo restrito:", e)
  }
}

export function disableRestrictedGroupMode(): void {
  if (typeof window === "undefined") return
  try {
    sessionStorage.removeItem(RESTRICTED_MODE_STORAGE_KEY)
    localStorage.removeItem(RESTRICTED_MODE_STORAGE_KEY)
  } catch (e) {
    console.warn("Não foi possível limpar estado do modo restrito:", e)
  }
}
