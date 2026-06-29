/**
 * Lista de todos os campos que devem estar preenchidos para que um perfil seja considerado completo.
 * Se você adicionar uma nova coluna obrigatória no banco, adicione o nome dela aqui.
 */
export const MANDATORY_PROFILE_FIELDS = {
    full_name: "Nome Completo",
    birth_date: "Data de Nascimento",
    gender: "Gênero",
    marital_status: "Estado Civil",
    cpf: "CPF",
    phone: "Telefone",
    address_street: "Rua",
    address_number: "Número",
    address_neighborhood: "Bairro",
    address_city: "Cidade",
    address_state: "Estado",
    address_zip_code: "CEP",
    occupation: "Profissão",
    education_level: "Escolaridade",
    employment_status: "Vínculo Empregatício",
    household_income: "Renda Familiar",
    dependents_count: "Número de Dependentes",
    housing_status: "Situação de Moradia",
    drivers_license: "CNH"
} as const;

export type MandatoryProfileField = keyof typeof MANDATORY_PROFILE_FIELDS;

/**
 * Verifica se o perfil contém algum valor "sentinela" ou está vazio para campos obrigatórios.
 */
export function isFieldComplete(value: any): boolean {
    if (value === null || value === undefined || value === "") return false;
    if (typeof value === "string") {
        const lower = value.toLowerCase();
        return lower !== "não informado" && lower !== "pendente";
    }
    return true;
}

export function getMissingProfileFields(profile: Record<string, any>): MandatoryProfileField[] {
    return (Object.keys(MANDATORY_PROFILE_FIELDS) as MandatoryProfileField[]).filter(
        field => !isFieldComplete(profile[field])
    );
}

export function getFieldLabel(field: string): string {
    return MANDATORY_PROFILE_FIELDS[field as MandatoryProfileField] || field;
}

export function isProfileComplete(profile: Record<string, any>): boolean {
    return getMissingProfileFields(profile).length === 0;
}
