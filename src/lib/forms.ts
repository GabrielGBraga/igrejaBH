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
