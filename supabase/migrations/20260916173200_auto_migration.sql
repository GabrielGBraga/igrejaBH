alter table "public"."retreats" add column "spreadsheet_data" jsonb default '{}'::jsonb;
set check_function_bodies = off;
CREATE OR REPLACE FUNCTION public.patch_retreat_sheet_metadata(p_retreat_id uuid, p_sheet_name text, p_metadata jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE public.retreats
  SET spreadsheet_data = jsonb_set(
    COALESCE(spreadsheet_data, '{}'::jsonb),
    ARRAY['_sheets', p_sheet_name],
    p_metadata,
    true
  )
  WHERE id = p_retreat_id;
END;
$function$
;
CREATE OR REPLACE FUNCTION public.patch_retreat_spreadsheet_cell(p_retreat_id uuid, p_sheet_name text, p_cell_coord text, p_value jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  UPDATE public.retreats
  SET spreadsheet_data = jsonb_set(
    COALESCE(spreadsheet_data, '{}'::jsonb),
    ARRAY[p_sheet_name, p_cell_coord],
    p_value,
    true
  )
  WHERE id = p_retreat_id;
END;
$function$
;
