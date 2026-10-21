/*
 * ============================================================================
 *  Tails Utils: Attachment Lister  -  v1.0.0
 * ============================================================================
 *  Da los nombres EXACTOS de los attachments del modelo del survivor (o de
 *  cualquier .mdl del juego) para elegir bien tails_anchor / puntos de anclaje.
 *
 *  COMANDOS:
 *    sm_atts [jugador]            Lista TODOS los attachments del modelo:
 *                                 1) parser binario del .mdl (nombres exactos
 *                                    de la seccion local de attachments)
 *                                 2) chequeo runtime con LookupEntityAttachment
 *                                    (incluye los heredados de $includemodel)
 *                                 Con posicion y angulos reales de cada punto.
 *    sm_attstest <nombre> [jug]   Prueba UN nombre en runtime (idx + pos + ang).
 *    sm_attsmodel <models/x.mdl>  Parsea cualquier .mdl del juego (sin runtime).
 *
 *  NOTA TECNICA:
 *    El .mdl empieza con studiohdr_t. La seccion de attachments se describe con
 *    [numlocalattachments][localattachmentindex] y cada mstudioattachment_t
 *    empieza con nameoffset (offset del nombre dentro del archivo). Las
 *    versiones de Source varian levemente de layout, asi que se prueban offsets
 *    de cabecera {0x118, 0x110, 0x114} y strides {60, 56, 52, 64}, y el
 *    resultado se VALIDA: todos los offsets deben caer dentro del archivo y
 *    todos los nombres ser ASCII imprimibles. El que valida gana. Luego todo
 *    se verifica en runtime con LookupEntityAttachment: si el parser se hubiera
 *    equivocado de seccion, los nombres no resolverian (idx 0).
 * ============================================================================
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>

#define PLUGIN_VERSION "1.0.0"
#define MAX_ATTS        128
#define NAME_LEN        64
#define TAG             "[ATTS]"

public Plugin myinfo =
{
	name        = "Tails Utils: Attachment Lister",
	author      = "OM / Super Z",
	description = "Lista los nombres EXACTOS de los attachments del modelo (.mdl + verificacion runtime)",
	version     = PLUGIN_VERSION,
	url         = ""
};

// ---------------------------------------------------------------------------
// Nombres conocidos de attachments de modelos Valve (valvebiped / survivors
// L4D2 / puntos de equipo). Sirven para el chequeo runtime por brute-force:
// cubren los attachments HEREDADOS de los $includemodel, que NO viven en el
// .mdl principal y que por tanto el parser no ve.
// ---------------------------------------------------------------------------
static const char g_Known[][] =
{
	"forward", "eyes", "head", "chest", "spine",
	"spine0", "spine1", "spine2", "spine3", "spine4", "spine5",
	"neck", "pelvis", "hips", "root", "valvebiped.root",
	"lhand", "rhand", "lefthand", "righthand",
	"lfoot", "rfoot", "leftfoot", "rightfoot",
	"anim_attachment_LH", "anim_attachment_RH",
	"anim_attachment_head", "anim_attachment_chest",
	"medkit", "pills", "primary", "secondary", "melee",
	"molotov", "pipebomb", "gascan", "laser_sight", "upgrade_laser_sight",
	"vest", "tankbutt", "flashlight", "muzzle"
};

// Candidatos "estables" para anclar el avatar de Tails (tails_anchor):
// puntos centrales/altos del esqueleto que apenas se mueven con animaciones.
static const char g_AnchorCandidates[][] =
{
	"root", "valvebiped.root", "pelvis", "hips",
	"spine3", "spine4", "chest", "medkit", "pills"
};

// Resultado del parser (nombres locales del .mdl)
static char g_AttNames[MAX_ATTS][NAME_LEN];
static int  g_AttCount = -1;   // -1 = fallo de parseo, 0 = sin locales, >0 = hay

// Candidatos de layout studiohdr a probar (numlocalattachments @ offset)
static int g_HdrCandidates[]    = { 0x118, 0x110, 0x114 };
static int g_StrideCandidates[] = { 60, 56, 52, 64 };

// ===========================================================================
//  REGISTRO
// ===========================================================================
public void OnPluginStart()
{
	RegConsoleCmd("sm_atts",        Cmd_Atts,      "sm_atts [jugador] - lista los attachments EXACTOS del modelo del survivor");
	RegConsoleCmd("sm_attachments", Cmd_Atts,      "sm_atts [jugador] - lista los attachments EXACTOS del modelo");
	RegConsoleCmd("sm_attstest",    Cmd_AttsTest,  "sm_attstest <nombre> [jugador] - prueba UN attachment en runtime (idx + pos + ang)");
	RegConsoleCmd("sm_attsmodel",   Cmd_AttsModel, "sm_attsmodel <models/ruta.mdl> - parsea cualquier .mdl del juego");
	LoadTranslations("common.phrases");
}

// ===========================================================================
//  sm_atts [jugador]
// ===========================================================================
Action Cmd_Atts(int client, int args)
{
	int target = client;

	if (args >= 1)
	{
		char arg[64];
		GetCmdArg(1, arg, sizeof(arg));
		target = FindTarget(client, arg, false, false);
		if (target == -1)
			return Plugin_Handled;
	}

	if (target <= 0)
	{
		ReplyToCommand(client, "%s Desde la consola del server usa: sm_atts <jugador>", TAG);
		return Plugin_Handled;
	}
	if (!IsClientInGame(target))
	{
		ReplyToCommand(client, "%s El jugador no esta en juego.", TAG);
		return Plugin_Handled;
	}

	char model[PLATFORM_MAX_PATH];
	GetEntPropString(target, Prop_Data, "m_ModelName", model, sizeof(model));

	ReplyToCommand(client, "%s ============================================================", TAG);
	ReplyToCommand(client, "%s  ATTACHMENTS DEL MODELO DE: %N", TAG, target);
	ReplyToCommand(client, "%s  Modelo : %s", TAG, model);

	// ---- 1. Parser binario del .mdl ---------------------------------------
	int hdrOff = -1, stride = -1, ver = 0, fsize = 0;
	char internal[65];
	bool parsed = ParseModel(model, hdrOff, stride, ver, fsize, internal);

	if (parsed)
	{
		ReplyToCommand(client, "%s  MDL    : version %d, %d bytes, parser OK (hdr 0x%X, stride %d, %d locales)",
		               TAG, ver, fsize, hdrOff, stride, g_AttCount);
		if (strlen(internal) > 0)
			ReplyToCommand(client, "%s  Interno: %s", TAG, internal);
		if (g_AttCount == 0)
			ReplyToCommand(client, "%s  El .mdl NO tiene attachments locales -> todo viene de $includemodel.", TAG);
	}
	else
	{
		ReplyToCommand(client, "%s  MDL    : no se pudo parsear -> se usara SOLO el chequeo runtime.", TAG);
	}

	// ---- 2. Listado con verificacion runtime ------------------------------
	float base[3];
	GetClientAbsOrigin(target, base);

	int shown = 0;

	if (parsed && g_AttCount > 0)
	{
		ReplyToCommand(client, "%s ------------------------------------------------------------", TAG);
		ReplyToCommand(client, "%s  ATTACHMENTS LOCALES DEL .MDL (nombres EXACTOS):", TAG);
		ReplyToCommand(client, "%s  (pos y ang relativos al survivor, snapshot PARADO)", TAG);
		ReplyToCommand(client, "%s ------------------------------------------------------------", TAG);
		for (int i = 0; i < g_AttCount; i++)
			shown += PrintOneAtt(client, target, g_AttNames[i], base);
	}

	// ---- 3. Brute-force runtime de nombres conocidos (heredados) ----------
	ReplyToCommand(client, "%s ------------------------------------------------------------", TAG);
	ReplyToCommand(client, "%s  CHEQUEO RUNTIME DE NOMBRES CONOCIDOS (incluye heredados):", TAG);
	ReplyToCommand(client, "%s ------------------------------------------------------------", TAG);
	int extra = 0;
	for (int k = 0; k < sizeof(g_Known); k++)
	{
		if (ParsedHas(g_Known[k]))
			continue;   // ya listado arriba
		if (LookupEntityAttachment(target, g_Known[k]) > 0)
		{
			shown += PrintOneAtt(client, target, g_Known[k], base);
			extra++;
		}
	}
	if (extra == 0 && (!parsed || g_AttCount == 0))
		ReplyToCommand(client, "%s   (ningun nombre conocido resuelve en runtime)", TAG);

	// ---- 4. Recomendacion para tails_anchor -------------------------------
	ReplyToCommand(client, "%s ------------------------------------------------------------", TAG);
	char cands[256];
	cands[0] = 0;
	for (int c = 0; c < sizeof(g_AnchorCandidates); c++)
	{
		if (ParsedHas(g_AnchorCandidates[c]) || LookupEntityAttachment(target, g_AnchorCandidates[c]) > 0)
		{
			if (cands[0] != 0)
				StrCat(cands, sizeof(cands), ", ");
			StrCat(cands, sizeof(cands), g_AnchorCandidates[c]);
		}
	}
	if (cands[0] != 0)
		ReplyToCommand(client, "%s  Para tails_anchor (Tails) prueba: %s", TAG, cands);
	else
		ReplyToCommand(client, "%s  Ningun candidato estable resolvio - copiame la lista completa de arriba.", TAG);
	ReplyToCommand(client, "%s ============================================================", TAG);

	if (client > 0)
		PrintToChat(client, "\x04[ATTS]\x01 %d attachments listados - abre tu consola (~) para verlos.", shown);

	return Plugin_Handled;
}

// ===========================================================================
//  sm_attstest <nombre> [jugador]
// ===========================================================================
Action Cmd_AttsTest(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "%s Uso: sm_attstest <nombreAttachment> [jugador]", TAG);
		return Plugin_Handled;
	}

	char name[64];
	GetCmdArg(1, name, sizeof(name));

	int target = client;
	if (args >= 2)
	{
		char arg2[64];
		GetCmdArg(2, arg2, sizeof(arg2));
		target = FindTarget(client, arg2, false, false);
		if (target == -1)
			return Plugin_Handled;
	}

	if (target <= 0)
	{
		ReplyToCommand(client, "%s Desde consola del server usa: sm_attstest <nombre> <jugador>", TAG);
		return Plugin_Handled;
	}
	if (!IsClientInGame(target))
	{
		ReplyToCommand(client, "%s El jugador no esta en juego.", TAG);
		return Plugin_Handled;
	}

	int rt = LookupEntityAttachment(target, name);
	if (rt <= 0)
	{
		ReplyToCommand(client, "%s  \"%s\" NO existe en el modelo de %N (idx 0) - el motor ignoraria ese nombre.", TAG, name, target);
		return Plugin_Handled;
	}

	float base[3];
	GetClientAbsOrigin(target, base);
	float org[3], ang[3];
	if (GetEntityAttachment(target, rt, org, ang))
	{
		ReplyToCommand(client, "%s  \"%s\" -> idx %d | dz %.1f | pos rel (%.1f, %.1f, %.1f) | ang (%.0f, %.0f, %.0f)",
		               TAG, name, rt, org[2] - base[2],
		               org[0] - base[0], org[1] - base[1], org[2] - base[2],
		               ang[0], ang[1], ang[2]);
	}
	else
	{
		ReplyToCommand(client, "%s  \"%s\" -> idx %d (el motor no devolvio posicion en este frame)", TAG, name, rt);
	}
	return Plugin_Handled;
}

// ===========================================================================
//  sm_attsmodel <models/ruta.mdl>
// ===========================================================================
Action Cmd_AttsModel(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "%s Uso: sm_attsmodel <models/ruta/modelo.mdl>  (ej: models/survivors/survivor_gambler.mdl)", TAG);
		return Plugin_Handled;
	}

	char path[PLATFORM_MAX_PATH];
	GetCmdArg(1, path, sizeof(path));
	if (StrContains(path, ".mdl") == -1)
	{
		ReplyToCommand(client, "%s La ruta debe terminar en .mdl", TAG);
		return Plugin_Handled;
	}

	int hdrOff = -1, stride = -1, ver = 0, fsize = 0;
	char internal[65];
	if (!ParseModel(path, hdrOff, stride, ver, fsize, internal))
	{
		ReplyToCommand(client, "%s No se pudo abrir o parsear: %s (revisa la ruta; debe existir en el juego)", TAG, path);
		return Plugin_Handled;
	}

	ReplyToCommand(client, "%s ============================================================", TAG);
	ReplyToCommand(client, "%s  ATTACHMENTS LOCALES DE: %s", TAG, path);
	ReplyToCommand(client, "%s  MDL    : version %d, %d bytes, parser OK (hdr 0x%X, stride %d)", TAG, ver, fsize, hdrOff, stride);
	if (strlen(internal) > 0)
		ReplyToCommand(client, "%s  Interno: %s", TAG, internal);

	if (g_AttCount == 0)
	{
		ReplyToCommand(client, "%s  El .mdl NO tiene attachments locales (vienen de $includemodel).", TAG);
	}
	else
	{
		for (int i = 0; i < g_AttCount; i++)
			ReplyToCommand(client, "%s   %3d. %s", TAG, i + 1, g_AttNames[i]);
	}
	ReplyToCommand(client, "%s ============================================================", TAG);
	return Plugin_Handled;
}

// ===========================================================================
//  PARSER BINARIO DEL .MDL
// ===========================================================================

// Abre un .mdl del juego (prueba: VPK/GAME, VPK/DEFAULT, y sistema de archivos
// plano relativo a la carpeta del mod).
File OpenModelFile(const char[] path)
{
	File f = OpenFile(path, "rb", true, "GAME");
	if (f == null)
		f = OpenFile(path, "rb", true, "DEFAULT");
	if (f == null)
		f = OpenFile(path, "rb");
	return f;
}

// Parsea el .mdl. Devuelve true si el archivo es un MDL valido y el layout se
// resolvio. Rellena g_AttNames/g_AttCount y los parametros de diagnostico.
bool ParseModel(const char[] path, int &outHdrOff, int &outStride, int &outVer, int &outSize, char outInternal[65])
{
	g_AttCount = -1;
	outHdrOff  = -1;
	outStride  = -1;
	outInternal[0] = 0;

	File f = OpenModelFile(path);
	if (f == null)
		return false;

	// Tamano total via seek al final
	f.Seek(0, SEEK_END);
	int fsize = f.Position;
	f.Seek(0, SEEK_SET);
	outSize = fsize;
	if (fsize < 0x200)
	{
		delete f;
		return false;
	}

	// Magic "IDST" + version + nombre interno
	char magic[8];
	f.Seek(0, SEEK_SET);
	f.ReadString(magic, 5, 4);
	magic[4] = 0;
	if (!StrEqual(magic, "IDST"))
	{
		delete f;
		return false;
	}

	int ver;
	f.ReadInt32(ver);
	outVer = ver;

	f.Seek(12, SEEK_SET);
	f.ReadString(outInternal, 64, 63);
	outInternal[63] = 0;

	// Probar combos (offset de cabecera x stride) hasta que uno valide
	bool valid = false;
	int count = -1;
	for (int h = 0; h < sizeof(g_HdrCandidates) && !valid; h++)
	{
		for (int s = 0; s < sizeof(g_StrideCandidates) && !valid; s++)
		{
			if (TryCombo(f, fsize, g_HdrCandidates[h], g_StrideCandidates[s], count))
			{
				valid     = true;
				outHdrOff = g_HdrCandidates[h];
				outStride = g_StrideCandidates[s];
				g_AttCount = count;
			}
		}
	}

	delete f;
	return valid;
}

// Prueba un layout concreto: lee [num][idx] en hdrOff, camina los structs con
// el stride dado y valida cada nameoffset y cada nombre (ASCII imprimible).
bool TryCombo(File f, int fsize, int hdrOff, int stride, int &count)
{
	count = -1;

	int num, idx;
	f.Seek(hdrOff, SEEK_SET);
	if (!f.ReadInt32(num))
		return false;
	if (!f.ReadInt32(idx))
		return false;

	// Caso "0 attachments locales" limpio: contador 0 e indice 0
	if (num == 0 && idx == 0)
	{
		count = 0;
		return true;
	}

	if (num < 1 || num > MAX_ATTS)
		return false;
	if (idx <= hdrOff + 8)                 // la seccion debe empezar tras la cabecera
		return false;
	if (idx + num * stride > fsize)        // y caber entera en el archivo
		return false;

	// Offset del nombre de cada attachment (primer campo del struct)
	int[] offs = new int[num];
	for (int i = 0; i < num; i++)
	{
		f.Seek(idx + i * stride, SEEK_SET);
		if (!f.ReadInt32(offs[i]))
			return false;
		if (offs[i] <= 0 || offs[i] >= fsize)
			return false;
	}

	// Leer y validar cada nombre
	char buf[NAME_LEN + 2];
	for (int i = 0; i < num; i++)
	{
		int room = fsize - offs[i];
		if (room < 1)
			return false;
		if (room > NAME_LEN - 1)
			room = NAME_LEN - 1;

		f.Seek(offs[i], SEEK_SET);
		int got = f.ReadString(buf, NAME_LEN + 2, room);
		if (got < 1)
			return false;
		buf[got] = 0;
		if (!IsValidName(buf))
			return false;
		strcopy(g_AttNames[i], NAME_LEN, buf);
	}

	count = num;
	return true;
}

// Un nombre de attachment valido: 1..40 chars ASCII imprimibles
bool IsValidName(const char[] s)
{
	int n = strlen(s);
	if (n < 1 || n > 40)
		return false;
	for (int i = 0; i < n; i++)
	{
		int c = view_as<int>(s[i]);
		if (c < 0x20 || c > 0x7E)
			return false;
	}
	return true;
}

// ===========================================================================
//  HELPERS DE SALIDA
// ===========================================================================

// Imprime UN attachment con su resolucion runtime + posicion/angulos.
// Devuelve 1 si resolvio en runtime, 0 si no.
int PrintOneAtt(int client, int target, const char[] name, const float base[3])
{
	int rt = LookupEntityAttachment(target, name);
	if (rt <= 0)
	{
		// Solo puede pasar si el parser leyo una seccion equivocada
		ReplyToCommand(client, "%s   %-24s  [parser dice que existe pero NO resuelve en runtime]", TAG, name);
		return 0;
	}

	float org[3], ang[3];
	if (!GetEntityAttachment(target, rt, org, ang))
	{
		ReplyToCommand(client, "%s   %-24s  idx %3d  (sin posicion este frame)", TAG, name, rt);
		return 1;
	}

	ReplyToCommand(client, "%s   %-24s  idx %3d  dz %6.1f  pos rel (%5.1f, %5.1f)  ang (%4.0f, %4.0f, %4.0f)",
	               TAG, name, rt, org[2] - base[2],
	               org[0] - base[0], org[1] - base[1],
	               ang[0], ang[1], ang[2]);
	return 1;
}

// El nombre ya fue listado por el parser?
bool ParsedHas(const char[] name)
{
	if (g_AttCount < 1)
		return false;
	for (int i = 0; i < g_AttCount; i++)
	{
		if (StrEqual(g_AttNames[i], name))
			return true;
	}
	return false;
}
