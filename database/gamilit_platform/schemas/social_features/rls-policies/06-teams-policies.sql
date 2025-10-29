-- =====================================================
-- RLS Policies for: social_features.team_members & team_challenges
-- Description: Team collaboration with member-based access
-- Created: 2025-10-28
-- =====================================================
--
-- Security Strategy:
-- - Team members can see their own teams and teammates
-- - Team challenges are visible to team members
-- - Privacy: Users cannot see teams they don't belong to
-- =====================================================

-- =====================================================
-- TABLE: social_features.team_members
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS team_members_read_own ON social_features.team_members;

-- Policy: team_members_read_own
-- Purpose: Users can see members of teams they belong to
CREATE POLICY team_members_read_own
    ON social_features.team_members
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        user_id = current_setting('app.current_user_id', true)::uuid
        OR team_id IN (
            SELECT team_id
            FROM social_features.team_members
            WHERE user_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY team_members_read_own ON social_features.team_members IS
    'Users can see all members of teams they belong to';

-- =====================================================
-- TABLE: social_features.team_challenges
-- Policies: 1 (SELECT: 1)
-- =====================================================

DROP POLICY IF EXISTS team_challenges_read_members ON social_features.team_challenges;

-- Policy: team_challenges_read_members
-- Purpose: Team members can see challenges for their teams
CREATE POLICY team_challenges_read_members
    ON social_features.team_challenges
    AS PERMISSIVE
    FOR SELECT
    TO public
    USING (
        team_id IN (
            SELECT team_id
            FROM social_features.team_members
            WHERE user_id = current_setting('app.current_user_id', true)::uuid
        )
    );

COMMENT ON POLICY team_challenges_read_members ON social_features.team_challenges IS
    'Users can see challenges for teams they are members of';

-- =====================================================
-- SUMMARY: social_features.teams tables
-- =====================================================
-- team_members: 1 policy (1 SELECT)
-- team_challenges: 1 policy (1 SELECT)
-- =====================================================
