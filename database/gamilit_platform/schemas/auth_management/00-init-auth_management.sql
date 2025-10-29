-- =====================================================
-- Auth Management Schema - Initialization Script
-- =====================================================
-- Description: Inicializa todo el schema auth_management
-- Date: 2025-10-28
-- =====================================================

\echo '=================================================='
\echo 'Initializing auth_management schema...'
\echo '=================================================='

-- ============================================
-- TABLES
-- ============================================
\echo 'Creating auth_management tables...'
\i tables/01-tenants.sql
\i tables/02-profiles.sql
\i tables/03-user_roles.sql
\i tables/04-memberships.sql
\i tables/05-auth_attempts.sql
\i tables/06-user_sessions.sql
\i tables/07-email_verification_tokens.sql
\i tables/08-password_reset_tokens.sql
\i tables/09-security_events.sql
\i tables/10-user_preferences.sql

-- ============================================
-- FUNCTIONS
-- ============================================
\echo 'Creating auth_management functions...'
\i functions/01-handle_new_user.sql
\i functions/02-cleanup_expired_sessions.sql
\i functions/03-update_auth_attempts_updated_at.sql
\i functions/04-update_email_verification_tokens_updated_at.sql
\i functions/05-update_memberships_updated_at.sql
\i functions/06-update_password_reset_tokens_updated_at.sql
\i functions/07-update_profiles_updated_at.sql
\i functions/08-update_security_events_updated_at.sql
\i functions/09-update_tenants_updated_at.sql
\i functions/10-update_user_roles_updated_at.sql
\i functions/11-update_user_sessions_updated_at.sql

-- ============================================
-- TRIGGERS
-- ============================================
\echo 'Creating auth_management triggers...'
\i triggers/01-tenants_updated_at.sql
\i triggers/02-profiles_updated_at.sql
\i triggers/03-user_roles_updated_at.sql
\i triggers/04-user_sessions_updated_at.sql
\i triggers/05-memberships_updated_at.sql
\i triggers/06-email_verification_tokens_updated_at.sql
\i triggers/07-password_reset_tokens_updated_at.sql
\i triggers/08-auth_attempts_updated_at.sql
\i triggers/09-security_events_updated_at.sql
\i triggers/10-trg_new_user_initialize.sql
\i triggers/11-trg_profile_changes_audit.sql

-- ============================================
-- INDEXES
-- ============================================
\echo 'Creating auth_management indexes...'
\i indexes/01-tenants.sql
\i indexes/02-profiles.sql
\i indexes/03-user_roles.sql
\i indexes/04-memberships.sql
\i indexes/05-user_sessions.sql
\i indexes/06-auth_attempts.sql
\i indexes/07-email_verification_tokens.sql
\i indexes/08-password_reset_tokens.sql
\i indexes/09-security_events.sql

-- ============================================
-- RLS POLICIES
-- ============================================
\echo 'Enabling RLS and creating policies...'
\i rls-policies/01-enable-rls.sql
\i rls-policies/02-policies.sql
\i rls-policies/03-grants.sql

\echo 'auth_management schema initialized successfully!'
