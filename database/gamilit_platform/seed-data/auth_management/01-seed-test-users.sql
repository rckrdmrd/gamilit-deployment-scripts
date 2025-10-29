-- =====================================================
-- Seed Data: Test Users for Development
-- Description: Creates test users with predefined credentials
-- Created: 2025-10-28
-- =====================================================

SET search_path TO auth_management, auth, public;

-- =====================================================
-- 1. Create Default Tenant
-- =====================================================

-- Insert default tenant for test users
INSERT INTO auth_management.tenants (
    id,
    name,
    slug,
    domain,
    subscription_tier,
    max_users,
    max_storage_gb,
    is_active,
    settings,
    metadata,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000001'::uuid,
    'Gamilit Test Organization',
    'gamilit-test',
    'test.gamilit.com',
    'enterprise',
    1000,
    100,
    true,
    '{"theme": "detective", "features": {"analytics_enabled": true, "gamification_enabled": true, "social_features_enabled": true}, "language": "es", "timezone": "America/Mexico_City"}'::jsonb,
    '{"description": "Default tenant for test users", "environment": "development"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. Create Test Users in auth.users
-- =====================================================

-- Test Student User
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    role,
    email_confirmed_at,
    last_sign_in_at,
    raw_user_meta_data,
    created_at,
    updated_at
) VALUES (
    '10000000-0000-0000-0000-000000000001'::uuid,
    'student@gamilit.com',
    '$2a$10$jcD1M4080L7RBFYGbrNZouyKUiod7fqVF2U8eqbgtkIIA6.fXLtkC', -- Test1234
    'student',
    NOW(),
    NULL,
    '{"firstName": "Test", "lastName": "Student", "fullName": "Test Student", "displayName": "Test Student"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Test Teacher User
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    role,
    email_confirmed_at,
    last_sign_in_at,
    raw_user_meta_data,
    created_at,
    updated_at
) VALUES (
    '20000000-0000-0000-0000-000000000001'::uuid,
    'teacher@gamilit.com',
    '$2a$10$jcD1M4080L7RBFYGbrNZouyKUiod7fqVF2U8eqbgtkIIA6.fXLtkC', -- Test1234
    'admin_teacher',
    NOW(),
    NULL,
    '{"firstName": "Test", "lastName": "Teacher", "fullName": "Test Teacher", "displayName": "Test Teacher"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Test Admin User
INSERT INTO auth.users (
    id,
    email,
    encrypted_password,
    role,
    email_confirmed_at,
    last_sign_in_at,
    raw_user_meta_data,
    created_at,
    updated_at
) VALUES (
    '30000000-0000-0000-0000-000000000001'::uuid,
    'admin@gamilit.com',
    '$2a$10$jcD1M4080L7RBFYGbrNZouyKUiod7fqVF2U8eqbgtkIIA6.fXLtkC', -- Test1234
    'super_admin',
    NOW(),
    NULL,
    '{"firstName": "Test", "lastName": "Admin", "fullName": "Test Admin", "displayName": "Test Admin"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- 3. Create Profiles for Test Users
-- =====================================================

-- Profile for Test Student
INSERT INTO auth_management.profiles (
    id,
    tenant_id,
    user_id,
    display_name,
    full_name,
    email,
    role,
    status,
    email_verified,
    grade_level,
    preferences,
    metadata,
    created_at,
    updated_at
) VALUES (
    '10000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    '10000000-0000-0000-0000-000000000001'::uuid,
    'Test Student',
    'Test Student',
    'student@gamilit.com',
    'student',
    'active',
    true,
    '6',
    '{"theme": "detective", "language": "es", "timezone": "America/Mexico_City", "sound_enabled": true, "notifications_enabled": true}'::jsonb,
    '{"test_account": true, "environment": "development"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Profile for Test Teacher
INSERT INTO auth_management.profiles (
    id,
    tenant_id,
    user_id,
    display_name,
    full_name,
    email,
    role,
    status,
    email_verified,
    preferences,
    metadata,
    created_at,
    updated_at
) VALUES (
    '20000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    '20000000-0000-0000-0000-000000000001'::uuid,
    'Test Teacher',
    'Test Teacher',
    'teacher@gamilit.com',
    'admin_teacher',
    'active',
    true,
    '{"theme": "detective", "language": "es", "timezone": "America/Mexico_City", "sound_enabled": true, "notifications_enabled": true}'::jsonb,
    '{"test_account": true, "environment": "development"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Profile for Test Admin
INSERT INTO auth_management.profiles (
    id,
    tenant_id,
    user_id,
    display_name,
    full_name,
    email,
    role,
    status,
    email_verified,
    preferences,
    metadata,
    created_at,
    updated_at
) VALUES (
    '30000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    '30000000-0000-0000-0000-000000000001'::uuid,
    'Test Admin',
    'Test Admin',
    'admin@gamilit.com',
    'super_admin',
    'active',
    true,
    '{"theme": "detective", "language": "es", "timezone": "America/Mexico_City", "sound_enabled": true, "notifications_enabled": true}'::jsonb,
    '{"test_account": true, "environment": "development"}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- 4. Assign Roles to Test Users
-- =====================================================

-- Assign student role
INSERT INTO auth_management.user_roles (
    id,
    user_id,
    tenant_id,
    role,
    permissions,
    is_active,
    metadata,
    created_at,
    updated_at
) VALUES (
    '10000000-0000-0000-0000-000000000001'::uuid,
    '10000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'student',
    '{"read": true, "write": false, "admin": false, "analytics": false}'::jsonb,
    true,
    '{"test_role": true}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (user_id, tenant_id, role) DO NOTHING;

-- Assign teacher role
INSERT INTO auth_management.user_roles (
    id,
    user_id,
    tenant_id,
    role,
    permissions,
    is_active,
    metadata,
    created_at,
    updated_at
) VALUES (
    '20000000-0000-0000-0000-000000000001'::uuid,
    '20000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'admin_teacher',
    '{"read": true, "write": true, "admin": false, "analytics": true}'::jsonb,
    true,
    '{"test_role": true}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (user_id, tenant_id, role) DO NOTHING;

-- Assign admin role
INSERT INTO auth_management.user_roles (
    id,
    user_id,
    tenant_id,
    role,
    permissions,
    is_active,
    metadata,
    created_at,
    updated_at
) VALUES (
    '30000000-0000-0000-0000-000000000001'::uuid,
    '30000000-0000-0000-0000-000000000001'::uuid,
    '00000000-0000-0000-0000-000000000001'::uuid,
    'super_admin',
    '{"read": true, "write": true, "admin": true, "analytics": true}'::jsonb,
    true,
    '{"test_role": true}'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (user_id, tenant_id, role) DO NOTHING;

-- =====================================================
-- Success Message
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Test users created successfully!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Student Account:';
    RAISE NOTICE '  Email: student@gamilit.com';
    RAISE NOTICE '  Password: Test1234';
    RAISE NOTICE '  Role: student';
    RAISE NOTICE '';
    RAISE NOTICE 'Teacher Account:';
    RAISE NOTICE '  Email: teacher@gamilit.com';
    RAISE NOTICE '  Password: Test1234';
    RAISE NOTICE '  Role: admin_teacher';
    RAISE NOTICE '';
    RAISE NOTICE 'Admin Account:';
    RAISE NOTICE '  Email: admin@gamilit.com';
    RAISE NOTICE '  Password: Test1234';
    RAISE NOTICE '  Role: super_admin';
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
END $$;
