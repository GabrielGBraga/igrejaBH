-- Protect is_dev column from unauthorized updates
-- Only users who already have is_dev = true can modify the is_dev field of any profile.
-- Other users can update their own profiles but is_dev will remain unchanged.

CREATE OR REPLACE FUNCTION public.handle_is_dev_protection()
RETURNS TRIGGER AS $$
BEGIN
    -- If the is_dev field is being changed
    IF (OLD.is_dev IS DISTINCT FROM NEW.is_dev) THEN
        -- Check if the current requester is a developer
        -- We check profiles.is_dev for the current auth.uid()
        IF NOT EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE user_id = auth.uid() AND is_dev = true
        ) THEN
            -- If not a developer, force the is_dev field to its old value
            NEW.is_dev := OLD.is_dev;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to execute before update
DROP TRIGGER IF EXISTS protect_is_dev_on_update ON public.profiles;
CREATE TRIGGER protect_is_dev_on_update
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_is_dev_protection();
