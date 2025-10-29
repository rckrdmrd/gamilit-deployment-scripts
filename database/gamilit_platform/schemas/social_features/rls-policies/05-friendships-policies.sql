-- =====================================================
-- RLS Policies for: social_features.friendships
-- Description: User friendship management with self-service access
-- Created: 2025-10-28
-- Policies: 3 (SELECT: 1, INSERT: 1, DELETE: 1)
-- =====================================================
--
-- Security Strategy:
-- - Self-managed: Users can only manage their own friendships
-- - Bidirectional visibility: Both users in a friendship can see it
-- - Privacy: Users cannot see other people's friendships
-- =====================================================

DROP POLICY IF EXISTS friendships_read_own ON social_features.friendships;
DROP POLICY IF EXISTS friendships_insert_own ON social_features.friendships;
DROP POLICY IF EXISTS friendships_delete_own ON social_features.friendships;

-- Policy: friendships_read_own
-- Purpose: Users can see their own friendships (both as user and friend)
CREATE POLICY friendships_read_own
    ON social_features.friendships
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        user_id = current_setting('app.current_user_id', true)::uuid
        OR friend_id = current_setting('app.current_user_id', true)::uuid
    );

COMMENT ON POLICY friendships_read_own ON social_features.friendships IS
    'Users can see friendships where they are either the user or the friend';

-- Policy: friendships_insert_own
-- Purpose: Users can create friendships where they are the user
CREATE POLICY friendships_insert_own
    ON social_features.friendships
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (user_id = current_setting('app.current_user_id', true)::uuid);

COMMENT ON POLICY friendships_insert_own ON social_features.friendships IS
    'Users can only create friendship requests from themselves';

-- Policy: friendships_delete_own
-- Purpose: Users can delete friendships where they are involved
CREATE POLICY friendships_delete_own
    ON social_features.friendships
    AS PERMISSIVE
    FOR DELETE
    TO public
    USING (
        user_id = current_setting('app.current_user_id', true)::uuid
        OR friend_id = current_setting('app.current_user_id', true)::uuid
    );

COMMENT ON POLICY friendships_delete_own ON social_features.friendships IS
    'Users can delete friendships they are part of (either as user or friend)';
