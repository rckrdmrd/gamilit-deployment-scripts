-- =====================================================
-- Function: audit_logging.log_audit_event
-- Description: Registra eventos de auditoría en system_logs
-- Priority: CRITICAL - Compliance requirement
-- Created: 2025-10-27
-- =====================================================

CREATE OR REPLACE FUNCTION audit_logging.log_audit_event(
    p_user_id uuid,
    p_action text,
    p_table_name text,
    p_record_id uuid DEFAULT NULL,
    p_old_data jsonb DEFAULT NULL,
    p_new_data jsonb DEFAULT NULL,
    p_ip_address inet DEFAULT NULL,
    p_user_agent text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_log_id uuid;
    v_tenant_id uuid;
BEGIN
    -- Get tenant_id from user profile
    SELECT tenant_id INTO v_tenant_id
    FROM auth_management.profiles
    WHERE id = p_user_id;

    -- Insert audit log
    INSERT INTO audit_logging.system_logs (
        id,
        tenant_id,
        user_id,
        action,
        table_name,
        record_id,
        old_data,
        new_data,
        ip_address,
        user_agent,
        created_at
    )
    VALUES (
        uuid_generate_v4(),
        v_tenant_id,
        p_user_id,
        p_action,
        p_table_name,
        p_record_id,
        p_old_data,
        p_new_data,
        p_ip_address,
        p_user_agent,
        NOW()
    )
    RETURNING id INTO v_log_id;

    RETURN v_log_id;
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the transaction
        RAISE WARNING 'Failed to log audit event: %', SQLERRM;
        RETURN NULL;
END;
$$;

COMMENT ON FUNCTION audit_logging.log_audit_event IS 'Registra eventos de auditoría en system_logs con manejo de errores';

-- Grant permissions
GRANT EXECUTE ON FUNCTION audit_logging.log_audit_event TO gamilit_user;
