#if defined _entity_guard_included
 #endinput
#endif
#define _entity_guard_included

/**
 * Returns the current count of networked entities (edicts) in the server.
 * Note: GetEntityCount() is often inaccurate for the edict count.
 *
 * @return				Number of networked entities.
 */
native int Guard_GetEdictCount();

/**
 * Returns the highest recorded edict count in the server since the map started.
 *
 * @return				Highest number of networked entities.
 */
native int Guard_GetPeakEdicts();

public SharedPlugin __pl_entity_guard =
{
	name = "Entity Guard",
	file = "entity_guard.smx",
	#if defined REQUIRE_PLUGIN
	required = 1
	#else
	required = 0
	#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_entity_guard_SetNTVOptional()
{
	MarkNativeAsOptional("Guard_GetEdictCount");
	MarkNativeAsOptional("Guard_GetPeakEdicts");
}
#endif
