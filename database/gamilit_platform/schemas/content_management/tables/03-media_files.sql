-- =====================================================
-- Table: content_management.media_files
-- Description: Archivos multimedia - imágenes, videos, audio, documentos
-- Created: 2025-10-27
-- =====================================================

SET search_path TO content_management, public;

DROP TABLE IF EXISTS content_management.media_files CASCADE;

CREATE TABLE content_management.media_files (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid,
    filename text NOT NULL,
    original_filename text NOT NULL,
    file_extension text,
    mime_type text,
    file_size_bytes bigint,
    media_type public.media_type NOT NULL,
    category text,
    subcategory text,
    storage_path text NOT NULL,
    public_url text,
    cdn_url text,
    thumbnail_url text,
    width integer,
    height integer,
    duration_seconds integer,
    bitrate integer,
    resolution text,
    color_profile text,
    alt_text text,
    caption text,
    description text,
    copyright_info text,
    license text,
    attribution text,
    processing_status public.processing_status DEFAULT 'ready'::public.processing_status,
    processing_info jsonb DEFAULT '{}'::jsonb,
    tags text[],
    keywords text[],
    folder_path text,
    usage_count integer DEFAULT 0,
    download_count integer DEFAULT 0,
    view_count integer DEFAULT 0,
    is_public boolean DEFAULT false,
    is_active boolean DEFAULT true,
    is_optimized boolean DEFAULT false,
    uploaded_by uuid,
    upload_session_id text,
    exif_data jsonb DEFAULT '{}'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    updated_at timestamp with time zone DEFAULT gamilit.now_mexico(),
    CONSTRAINT media_files_file_size_bytes_check CHECK ((file_size_bytes > 0))
);

ALTER TABLE content_management.media_files OWNER TO gamilit_user;

-- Primary Key
ALTER TABLE ONLY content_management.media_files
    ADD CONSTRAINT media_files_pkey PRIMARY KEY (id);

-- Indexes
CREATE INDEX idx_media_files_active ON content_management.media_files USING btree (is_active) WHERE (is_active = true);
CREATE INDEX idx_media_files_category ON content_management.media_files USING btree (category);
CREATE INDEX idx_media_files_tags ON content_management.media_files USING gin (tags);
CREATE INDEX idx_media_files_tenant ON content_management.media_files USING btree (tenant_id);
CREATE INDEX idx_media_files_type ON content_management.media_files USING btree (media_type);
CREATE INDEX idx_media_files_uploaded_by ON content_management.media_files USING btree (uploaded_by);

-- Triggers
CREATE TRIGGER trg_media_files_updated_at BEFORE UPDATE ON content_management.media_files FOR EACH ROW EXECUTE FUNCTION gamilit.update_updated_at_column();

-- Foreign Keys
ALTER TABLE ONLY content_management.media_files
    ADD CONSTRAINT media_files_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES auth_management.tenants(id) ON DELETE CASCADE;

ALTER TABLE ONLY content_management.media_files
    ADD CONSTRAINT media_files_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth_management.profiles(id);

-- Row Level Security
ALTER TABLE content_management.media_files ENABLE ROW LEVEL SECURITY;

-- Permissions
GRANT ALL ON TABLE content_management.media_files TO gamilit_user;

-- Comments
COMMENT ON TABLE content_management.media_files IS 'Archivos multimedia - imágenes, videos, audio, documentos';
COMMENT ON COLUMN content_management.media_files.media_type IS 'Tipo: image, video, audio, document, interactive, animation';
COMMENT ON COLUMN content_management.media_files.processing_status IS 'Estado: uploading, processing, ready, error, optimizing';
