#if defined _pure_ac130_effects_included
 #endinput
#endif
#define _pure_ac130_effects_included

// #define SHAKE_START            (0) // Starts the screen shake for all players within the radius
// #define SHAKE_STOP             (1) // Stops the screen shake for all players within the radius
// #define SHAKE_AMPLITUDE        (2) // Modifies the amplitude of an active screen shake for all players within the radius
// #define SHAKE_FREQUENCY        (3) // Modifies the frequency of an active screen shake for all players within the radius
// #define SHAKE_START_RUMBLEONLY (4) // Starts a shake effect that only rumbles the controller, no screen effect
// #define SHAKE_START_NORUMBLE   (5) // Starts a shake that does NOT rumble the controller
stock void ShakeScreen(int client, int cmd, float amplitude, float frequency, float duration)
{
    Handle shakeMsg = StartMessageOne("Shake", client, USERMSG_RELIABLE);
    if(shakeMsg != INVALID_HANDLE)
    {
        if(GetUserMessageType() == UM_BitBuf)
        {
            if (cmd == 0)
            {
                BfWriteByte(shakeMsg, 0);
            }
            if (cmd == 1)
            {
                BfWriteByte(shakeMsg, 1);
            }
            BfWriteFloat(shakeMsg, amplitude);
            BfWriteFloat(shakeMsg, frequency);
            BfWriteFloat(shakeMsg, duration);
            EndMessage();
        }
        else if(GetUserMessageType() == UM_Protobuf)
        {
            Protobuf pb = UserMessageToProtobuf(shakeMsg);
            if (cmd == 0)
            {
                pb.SetInt("command", 0);
            }
            if (cmd == 1)
            {
                pb.SetInt("command", 1);
            }

            pb.SetFloat("local_amplitude", amplitude);
            pb.SetFloat("frequency", frequency);
            pb.SetFloat("duration", duration);
            EndMessage();
        }
        else
        {
            PrintToServer("UserMessage Type Error");
            shakeMsg.Close();
        }
    }
}
