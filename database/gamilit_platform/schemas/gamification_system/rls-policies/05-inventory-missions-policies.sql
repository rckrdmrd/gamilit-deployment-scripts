-- =====================================================
-- RLS Policies for: gamification_system.comodines_inventory & missions
-- Description: User inventory and missions with self-service management
-- Created: 2025-10-28
-- =====================================================
--
-- Security Strategy:
-- - Inventory: Private, users manage their own power-ups
-- - Missions: Users see active missions, admins manage all
-- =====================================================

-- =====================================================
-- TABLE: gamification_system.comodines_inventory
-- Policies: 3 (SELECT: 1, UPDATE: 1, INSERT: 1)
-- =====================================================

DROP POLICY IF EXISTS comodines_read_own ON gamification_system.comodines_inventory;
DROP POLICY IF EXISTS comodines_update_own ON gamification_system.comodines_inventory;
DROP POLICY IF EXISTS comodines_insert_system ON gamification_system.comodines_inventory;

-- Policy: comodines_read_own
-- Purpose: Users can read their own inventory
CREATE POLICY comodines_read_own
    ON gamification_system.comodines_inventory
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY comodines_read_own ON gamification_system.comodines_inventory IS
    'Users can see their own power-up inventory';

-- Policy: comodines_update_own
-- Purpose: Users can update their inventory (use power-ups)
CREATE POLICY comodines_update_own
    ON gamification_system.comodines_inventory
    AS PERMISSIVE
    FOR UPDATE
    TO public
    USING (user_id = current_setting('app.current_user_id', true)::uuid)
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY comodines_update_own ON gamification_system.comodines_inventory IS
    'Users can update their inventory to use/consume power-ups';

-- Policy: comodines_insert_system
-- Purpose: System/Admin can create items in inventory (rewards)
CREATE POLICY comodines_insert_system
    ON gamification_system.comodines_inventory
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

COMMENT ON POLICY comodines_insert_system ON gamification_system.comodines_inventory IS
    'Only system can grant power-ups to users (via SECURITY DEFINER functions)';

-- =====================================================
-- TABLE: gamification_system.missions
-- Policies: 2 (SELECT: 1, ALL: 1)
-- =====================================================

DROP POLICY IF EXISTS missions_read_own ON gamification_system.missions;
DROP POLICY IF EXISTS missions_manage_admin ON gamification_system.missions;

-- Policy: missions_read_own
-- Purpose: Users can read their own active missions
CREATE POLICY missions_read_own
    ON gamification_system.missions
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        user_id = current_setting('app.current_user_id', true)::uuid
        AND status IN ('active', 'in_progress')
    );

COMMENT ON POLICY missions_read_own ON gamification_system.missions IS
    'Users can see their active and in-progress missions';

-- Policy: missions_manage_admin
-- Purpose: Admins can fully manage missions
CREATE POLICY missions_manage_admin
    ON gamification_system.missions
    AS PERMISSIVE
    FOR ALL
    TO public
    USING (
        EXISTS (
            SELECT 1 FROM auth_management.user_roles ur
            WHERE ur.user_id = current_setting('app.current_user_id', true)::uuid
                AND ur.role = 'super_admin'
        )
    );

COMMENT ON POLICY missions_manage_admin ON gamification_system.missions IS
    'Admins can create, update, and delete missions for users';
