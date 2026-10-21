AddCSLuaFile()
if SERVER then
end

--
if CLIENT then
    hook.Add( "PreDrawOutlines_om_optimized", "OM_highlight_Kolossos", function()
        om_halo.Add_optimized(
            function(ent) 
                return ent:GetNW2Float("kolossos_block_outline", 0) >= CurTime()
            end, 
            function(ent) 
                return Color(255, 255, 255, 255)
            end, 
            2, 
            false)              
    end )
end