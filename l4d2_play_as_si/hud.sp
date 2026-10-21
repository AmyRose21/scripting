#if defined _pure_play_as_si_hud_included
 #endinput
#endif
#define _pure_play_as_si_hud_included


public void DrawSelectSpecialMenuUI(int client)
{
    Menu menu = CreateMenu(SelectSpecialHandler);
    menu.SetTitle("Choose To Play As");
    menu.AddItem("1", "Smoker");
    menu.AddItem("2", "Boomer");
    menu.AddItem("3", "Hunter");
    menu.AddItem("4", "Spitter");
    menu.AddItem("5", "Jockey");
    menu.AddItem("6", "Charger");
    menu.AddItem("8", "Tank");
    DisplayMenu(menu, client, 0);
}

// typedef MenuHandler = function int (Menu menu, MenuAction action, int param1, int param2);
public int SelectSpecialHandler(Handle menu, MenuAction action, int client, int index)
{
    if (action == MenuAction_Select)
    {
        char info[4]; GetMenuItem(menu, index, info, 4);
        if(playerStatus[client] > 0)
        {
            PrintHintText(client, "Can not Use When Playing Survivor-SI");
        }
        char aug[8]; Format(aug, 8, "%d %s", client, info);
        CheatCommand(client, "sm_playassi", aug);
    }
    else
    {
        delete menu;
    }
    return 0;
}