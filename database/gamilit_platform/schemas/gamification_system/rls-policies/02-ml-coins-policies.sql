-- =====================================================
-- RLS Policies for: gamification_system.ml_coins_transactions
-- Description: ML Coins transactions with role-based access
-- Created: 2025-10-28
-- Policies: 4 (SELECT: 3, INSERT: 1)
-- =====================================================
--
-- Security Strategy:
-- - Self-service: Users can see their own transactions
-- - Teacher oversight: Teachers can see student transactions in their classrooms
-- - Admin monitoring: Admins can see all transactions
-- - System-controlled creation: Only admins can create transactions (via SECURITY DEFINER functions)
-- =====================================================

DROP POLICY IF EXISTS ml_coins_read_own ON gamification_system.ml_coins_transactions;
DROP POLICY IF EXISTS ml_coins_read_teacher ON gamification_system.ml_coins_transactions;
DROP POLICY IF EXISTS ml_coins_read_admin ON gamification_system.ml_coins_transactions;
DROP POLICY IF EXISTS ml_coins_insert_system ON gamification_system.ml_coins_transactions;

-- Policy: ml_coins_read_own
-- Purpose: Users can read their own transactions
CREATE POLICY ml_coins_read_own
    ON gamification_system.ml_coins_transactions
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY ml_coins_read_own ON gamification_system.ml_coins_transactions IS
    'Users can see their own ML Coins transaction history';

-- Policy: ml_coins_read_teacher
-- Purpose: Teachers can read transactions of students in their classrooms
CREATE POLICY ml_coins_read_teacher
    ON gamification_system.ml_coins_transactions
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'admin_teacher'
        )
        AND user_id IN (
            SELECT cm.student_id
            FROM social_features.classroom_members cm
            JOIN social_features.classrooms c ON c.id = cm.classroom_id
            WHERE c.teacher_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY ml_coins_read_teacher ON gamification_system.ml_coins_transactions IS
    'Teachers can monitor ML Coins transactions of students in their classrooms';

-- Policy: ml_coins_read_admin
-- Purpose: Admins can read all transactions
CREATE POLICY ml_coins_read_admin
    ON gamification_system.ml_coins_transactions
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY ml_coins_read_admin ON gamification_system.ml_coins_transactions IS
    'Admins can see all ML Coins transactions for monitoring and auditing';

-- Policy: ml_coins_insert_system
-- Purpose: Only system (admin) can create transactions
-- Note: In practice, this should be done via SECURITY DEFINER functions
CREATE POLICY ml_coins_insert_system
    ON gamification_system.ml_coins_transactions
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY ml_coins_insert_system ON gamification_system.ml_coins_transactions IS
    'Only system (via SECURITY DEFINER functions) can create ML Coins transactions';
