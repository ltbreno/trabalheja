-- Políticas de Storage para o bucket 'profiles'
-- Execute este script no SQL Editor do Supabase Dashboard

-- ============================================
-- POLÍTICA 1: INSERT (Upload) - Permitir upload apenas na própria pasta
-- ============================================
CREATE POLICY "Users can upload their own files"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- POLÍTICA 2: SELECT (Leitura) - Permitir leitura pública
-- ============================================
CREATE POLICY "Public can view profile files"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profiles');

-- ============================================
-- POLÍTICA 3: UPDATE (Atualização) - Permitir atualizar apenas próprios arquivos
-- ============================================
CREATE POLICY "Users can update their own files"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
  bucket_id = 'profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- POLÍTICA 4: DELETE (Exclusão) - Permitir deletar apenas próprios arquivos
-- ============================================
CREATE POLICY "Users can delete their own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profiles' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- NOTAS IMPORTANTES:
-- ============================================
-- 1. Se você já criou políticas anteriormente, você pode precisar deletá-las primeiro:
--    DROP POLICY IF EXISTS "Users can upload their own files" ON storage.objects;
--    DROP POLICY IF EXISTS "Public can view profile files" ON storage.objects;
--    DROP POLICY IF EXISTS "Users can update their own files" ON storage.objects;
--    DROP POLICY IF EXISTS "Users can delete their own files" ON storage.objects;
--
-- 2. A função `storage.foldername(name)[1]` extrai o primeiro segmento do caminho do arquivo.
--    Por exemplo, para o arquivo "user-id/portfolio/photo_1.jpg", retorna "user-id".
--
-- 3. Certifique-se de que o bucket 'profiles' está criado e configurado como público ou privado
--    conforme sua necessidade (público permite URLs diretas, privado requer signed URLs).
--
-- 4. Se você quiser que apenas usuários autenticados possam ver os arquivos (não público),
--    altere a política SELECT para usar 'authenticated' em vez de 'public'.

