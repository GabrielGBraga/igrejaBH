export interface FormField {
  id: string;
  type: 'text' | 'textarea' | 'number' | 'select' | 'checkbox' | 'radio' | 'date';
  label: string;
  placeholder: string;
  required: boolean;
  helpText: string;
  options: string[]; // for select, checkbox, radio

  // Conditional Display Logic
  dependsOnFieldId?: string;
  dependsOnValue?: string;

  // Validation Rules
  validationPreset?: 'none' | 'phone' | 'cpf' | 'cep' | 'email';
  minNumber?: number;
  maxNumber?: number;

  // Character limits for text and textarea
  minLength?: number;
  maxLength?: number;

  // CEP Auto fill mappings (stored on the CEP field itself)
  cepMapping?: {
    streetFieldId?: string;
    neighborhoodFieldId?: string;
    cityFieldId?: string;
    stateFieldId?: string;
  };

  // Layout Options
  halfWidth?: boolean;
}

export interface FormTemplate {
  id: string;
  name: string;
  description: string;
  fields: FormField[];
  createdAt: string;
  isPublic?: boolean;
}

export interface FormSubmission {
  id: string;
  formId: string;
  submittedAt: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: Record<string, any>;
}

// Helper to evaluate field visibility recursively based on current answers
export const isFieldVisible = (
  field: FormField,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: Record<string, any>,
  fieldsList: FormField[]
): boolean => {
  if (!field.dependsOnFieldId) return true;
  
  const parentField = fieldsList.find(f => f.id === field.dependsOnFieldId);
  if (!parentField) return true;

  // Check parent's visibility recursively
  if (!isFieldVisible(parentField, data, fieldsList)) return false;

  const parentValue = data[field.dependsOnFieldId];
  if (parentValue === undefined || parentValue === null) return false;

  const targetValue = field.dependsOnValue;
  if (!targetValue) return true; 

  if (Array.isArray(parentValue)) {
    return parentValue.includes(targetValue);
  }
  
  return String(parentValue) === String(targetValue);
};

/**
 * Validates a CPF using the standard mathematical digit-verification algorithm.
 */
export function isValidCPF(cpf: string): boolean {
  const clean = cpf.replace(/\D/g, "");
  if (clean.length !== 11) return false;

  // Reject known invalid patterns
  if (/^(\d)\1{10}$/.test(clean)) return false;

  // Validate first digit
  let sum = 0;
  for (let i = 0; i < 9; i++) {
    sum += parseInt(clean.charAt(i)) * (10 - i);
  }
  let rev = 11 - (sum % 11);
  if (rev === 10 || rev === 11) rev = 0;
  if (rev !== parseInt(clean.charAt(9))) return false;

  // Validate second digit
  sum = 0;
  for (let i = 0; i < 10; i++) {
    sum += parseInt(clean.charAt(i)) * (11 - i);
  }
  rev = 11 - (sum % 11);
  if (rev === 10 || rev === 11) rev = 0;
  if (rev !== parseInt(clean.charAt(10))) return false;

  return true;
}

/**
 * Validates a Brazilian mobile phone number (DDD + 9 + 8 digits).
 */
export function isValidPhone(phone: string): boolean {
  const clean = phone.replace(/\D/g, "");
  if (clean.length !== 11) return false;

  const ddd = parseInt(clean.substring(0, 2), 10);
  const VALID_DDDS = new Set([
    11, 12, 13, 14, 15, 16, 17, 18, 19,
    21, 22, 24, 27, 28,
    31, 32, 33, 34, 35, 37, 38,
    41, 42, 43, 44, 45, 46, 47, 48, 49,
    51, 53, 54, 55,
    61, 62, 63, 64, 65, 66, 67, 68, 69,
    71, 73, 74, 75, 77, 79,
    81, 82, 83, 84, 85, 86, 87, 88, 89,
    91, 92, 93, 94, 95, 96, 97, 98, 99
  ]);

  if (!VALID_DDDS.has(ddd)) return false;
  if (clean.charAt(2) !== '9') return false;

  return true;
}


/**
 * Automatically applies masks to Phone, CPF, and CEP inputs in real-time.
 */
export function formatValue(value: string, preset?: FormField['validationPreset']): string {
  if (!preset || preset === 'none') return value;

  const digits = value.replace(/\D/g, "");

  if (preset === 'cpf') {
    const clean = digits.slice(0, 11);
    let formatted = "";
    if (clean.length > 0) {
      formatted += clean.substring(0, 3);
    }
    if (clean.length > 3) {
      formatted += "." + clean.substring(3, 6);
    }
    if (clean.length > 6) {
      formatted += "." + clean.substring(6, 9);
    }
    if (clean.length > 9) {
      formatted += "-" + clean.substring(9, 11);
    }
    return formatted;
  }

  if (preset === 'cep') {
    const clean = digits.slice(0, 8);
    let formatted = "";
    if (clean.length > 0) {
      formatted += clean.substring(0, Math.min(clean.length, 5));
    }
    if (clean.length > 5) {
      formatted += "-" + clean.substring(5, 8);
    }
    return formatted;
  }

  if (preset === 'phone') {
    const clean = digits.slice(0, 11);
    let formatted = "";
    if (clean.length > 0) {
      formatted += "(" + clean.substring(0, Math.min(clean.length, 2));
    }
    if (clean.length > 2) {
      formatted += ") " + clean.substring(2, Math.min(clean.length, 7));
    }
    if (clean.length > 7) {
      if (clean.length > 10) {
        formatted = `(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7, 11)}`;
      } else {
        formatted = `(${clean.substring(0, 2)}) ${clean.substring(2, 6)}-${clean.substring(6, 10)}`;
      }
    }
    return formatted;
  }

  return value;
}

/**
 * Fetches location/address details from ViaCEP API.
 */
export async function fetchAddressFromCep(cep: string) {
  const clean = cep.replace(/\D/g, "");
  if (clean.length !== 8) return null;

  try {
    const res = await fetch(`https://viacep.com.br/ws/${clean}/json/`);
    if (!res.ok) return null;
    const data = await res.json();
    if (data.erro) return { error: true };
    return data; // returns { logradouro, bairro, localidade, uf, ... }
  } catch (err) {
    console.error("Error calling ViaCEP API:", err);
    return null;
  }
}

