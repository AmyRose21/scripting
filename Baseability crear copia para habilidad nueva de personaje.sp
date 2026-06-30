#include <sourcemod>
#include <SonicJumpSurvivors>

public void OnPluginStart()
{
    int sonicIndex = GetCharIndexByName("Sonic");
    if (sonicIndex != -1)
    {
        PrintToServer("✅ Sonic tiene índice %d, listo para habilidad especial!", sonicIndex);
    }
    else
    {
        PrintToServer("❌ No se encontró el índice de Sonic.");
    }
}

// Ejemplo: usar el índice del personaje del jugador
public void OnPlayerJump(int client)
{
    int charIndex = GetPlayerCharIndex(client);
    if (charIndex == -1) return;

    if (charIndex == GetCharIndexByName("Sonic"))
    {
        PrintCenterText(client, "Sonic usa su Doble Salto!");
        // Aplica tu lógica aquí...
    }
}