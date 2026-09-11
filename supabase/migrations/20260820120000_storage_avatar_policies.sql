-- Update storage.objects RLS policies for the avatars bucket
DROP POLICY IF EXISTS "Authenticated users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update their own avatar" ON storage.objects;

CREATE POLICY "Authenticated users can upload avatars"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (
    (auth.uid())::text = (storage.foldername(name))[1]
    OR name LIKE (auth.uid())::text || '%'
  )
);

CREATE POLICY "Authenticated users can update their own avatar"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (
    (auth.uid())::text = (storage.foldername(name))[1]
    OR name LIKE (auth.uid())::text || '%'
  )
);

CREATE POLICY "Authenticated users can delete their own avatar"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND (
    (auth.uid())::text = (storage.foldername(name))[1]
    OR name LIKE (auth.uid())::text || '%'
  )
);
