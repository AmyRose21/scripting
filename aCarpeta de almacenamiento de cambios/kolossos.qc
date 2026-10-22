// Created by Crowbar 0.74

$modelname "Noodles\OM\Kolossos.mdl"

$bodygroup "Body"
{
        studio "Kolossos.smd"
}


$surfaceprop "flesh"

$contents "solid"

$illumposition -0.026 0.438 26.808

$mostlyopaque

$cdmaterials "models\Noodles\OM\Kolossos\"

// v1.5.3: + walk/run/idle_swing (la fusion del M1) | v1.5.2: la MANO del agarre — el plugin v1.8 parenta a la victima a este
// punto (SetParent + SetParentAttachment "grabhand"): pegada al brazo EN
// SI y orientada a donde mira Kolossos (no el survivor invisible), con
// tilt afinable en vivo (kolossos_grab_tilt, default -35 = hacia abajo)
$attachment "grabhand" "RightHand" 0 0 0

$cbox 0 0 0 0 0 0

$bbox -40.074 -5.473 -0.195 39.198 5.422 53.812

$definebone "Root" "" 0 0 0 0 0 89.999982 0 0 0 0 0 0
$definebone "LowerTorso" "Root" 0 40.961914 -1.702296 0 0 0 0 0 0 0 0 0
$definebone "UpperTorso" "LowerTorso" 0 11.892838 0 0 0 6.93468 0 0 0 0 0 0
$definebone "Head" "UpperTorso" 0 13.850502 0.595224 0 0 -6.93468 0 0 0 0 0 0
$definebone "RightEye" "Head" -4.760352 6.611351 8.698524 0 0 0 0 0 0 0 0 0
$definebone "LeftEye" "Head" 4.760352 6.611351 8.698524 0 0 0 0 0 0 0 0 0
$definebone "RightUpperArm" "UpperTorso" -4.28802 6.809307 -0.658933 6.916403 85.819742 6.336167 0 0 0 0 0 0
$definebone "RightLowerArm" "RightUpperArm" 0 26.601686 0 0.18094 1.557185 -10.064579 0 0 0 0 0 0
$definebone "RightHand" "RightLowerArm" 0.000004 25.172943 0 0.091788 -1.696126 6.190005 0 0 0 0 0 0
$definebone "LeftUpperArm" "UpperTorso" 6.30666 7.720322 -1.606212 -6.93468 -89.999982 0 0 0 0 0 0 0
$definebone "LeftLowerArm" "LeftUpperArm" 0 11.691048 0 0 0 0 0 0 0 0 0 0
$definebone "LeftHand" "LeftLowerArm" 0.000008 13.782648 0 0 0 0 0 0 0 0 0 0
$definebone "LeftPinky1" "LeftHand" 0 10.863947 -3.319548 0 0 0 0 0 0 0 0 0
$definebone "LeftPinky2" "LeftPinky1" 0.000008 4.454521 0 0 0 0 0 0 0 0 0 0
$definebone "LeftMiddleFinger1" "LeftHand" 0 10.863947 0.21768 0 0 0 0 0 0 0 0 0
$definebone "LeftMiddleFinger2" "LeftMiddleFinger1" 0.000008 5.651737 0 0 0 0 0 0 0 0 0 0
$definebone "LeftPointyFinger1" "LeftHand" 0 10.863947 3.156288 0 0 0 0 0 0 0 0 0
$definebone "LeftPointyFinger2" "LeftPointyFinger1" 0 4.454521 0 0 0 0 0 0 0 0 0 0
$definebone "LeftThumb1" "LeftHand" 0.592743 2.938559 3.3927 8.905826 -7.845685 47.37049 0 0 0 0 0 0
$definebone "LeftThumb2" "LeftThumb1" -0.000008 5.320116 0 0 0 0 0 0 0 0 0 0
$definebone "RightUpperLeg" "LowerTorso" -2.108076 0.858227 -0.399024 -0.531304 -7.147076 176.243428 0 0 0 0 0 0
$definebone "RightLowerLeg" "RightUpperLeg" 0 13.130852 0 -0.272613 -0.571697 7.949959 0 0 0 0 0 0
$definebone "RightFoot" "RightLowerLeg" 0 16.703356 0 -0.700326 -6.561283 -72.107195 0 0 0 0 0 0
$definebone "LeftUpperLeg" "LowerTorso" 2.108076 0.858227 -0.399024 0.538523 7.154581 174.635629 0 0 0 0 0 0
$definebone "LeftLowerLeg" "LeftUpperLeg" 0 13.130833 0 0.267113 0.600459 10.802601 0 0 0 0 0 0
$definebone "LeftFoot" "LeftLowerLeg" -0.001812 16.690851 -0.646212 0.835831 6.532405 -73.344668 0 0 0 0 0 0


$sectionframes 30 250

$poseparameter "aim_yaw" -90 90 loop 0
$poseparameter "aim_pitch" -90 90 loop 0

$weightlist "weights_swingdeltatosequence" {
         "Root" 0
         "LowerTorso" 0
         "UpperTorso" 1
         "Head" 1
         "RightEye" 1
         "LeftEye" 1
         "RightUpperArm" 0
         "RightLowerArm" 0
         "RightHand" 0
         "LeftUpperArm" 0
         "LeftLowerArm" 0
         "LeftHand" 0
         "LeftPinky1" 0
         "LeftPinky2" 0
         "LeftMiddleFinger1" 0
         "LeftMiddleFinger2" 0
         "LeftPointyFinger1" 0
         "LeftPointyFinger2" 0
         "LeftThumb1" 0
         "LeftThumb2" 0
         "RightUpperLeg" 0
         "RightLowerLeg" 0
         "RightFoot" 0
         "LeftUpperLeg" 0
         "LeftLowerLeg" 0
         "LeftFoot" 0
}

$weightlist "weights_swing" {
         "Root" 0
         "LowerTorso" 0
         "UpperTorso" 0
         "Head" 0
         "RightEye" 0
         "LeftEye" 0
         "RightUpperArm" 1
         "RightLowerArm" 1
         "RightHand" 1
         "LeftUpperArm" 1
         "LeftLowerArm" 1
         "LeftHand" 1
         "LeftPinky1" 1
         "LeftPinky2" 1
         "LeftMiddleFinger1" 1
         "LeftMiddleFinger2" 1
         "LeftPointyFinger1" 1
         "LeftPointyFinger2" 1
         "LeftThumb1" 1
         "LeftThumb2" 1
         "RightUpperLeg" 0
         "RightLowerLeg" 0
         "RightFoot" 0
         "LeftUpperLeg" 0
         "LeftLowerLeg" 0
         "LeftFoot" 0
}

// v1.5.1-fix1: ELIMINADO el primer set de las 10 correctivas (10 bloques
// $animation VACIOS, duplicados por el decompile Crowbar 0.74). StudioMDL
// abortaba con "Duplicate animation name" en la 2da declaracion (linea 146
// del QC v1.5). Se conserva UNICO el set con fps 30, que es el que referencian
// los "subtract" de Look*/swingdelta/Grab*delta.

$animation "LookR_corrective_animation" "kolossos_anims\LookR_corrective_animation.smd" {
        fps 30
}

$animation "LookC_corrective_animation" "kolossos_anims\LookC_corrective_animation.smd" {
        fps 30
}

$animation "LookL_corrective_animation" "kolossos_anims\LookL_corrective_animation.smd" {
        fps 30
}

$animation "LookU_corrective_animation" "kolossos_anims\LookU_corrective_animation.smd" {
        fps 30
}

$animation "LookD_corrective_animation" "kolossos_anims\LookD_corrective_animation.smd" {
        fps 30
}

$animation "swingdelta_corrective_animation" "kolossos_anims\swingdelta_corrective_animation.smd" {
        fps 30
}

$animation "Grabdelta_corrective_animation" "kolossos_anims\Grabdelta_corrective_animation.smd" {
        fps 30
}

$animation "GrabIdledelta_corrective_animation" "kolossos_anims\GrabIdledelta_corrective_animation.smd" {
        fps 30
}

$animation "GrabPunchdelta_corrective_animation" "kolossos_anims\GrabPunchdelta_corrective_animation.smd" {
        fps 30
}

$animation "GrabThrowdelta_corrective_animation" "kolossos_anims\GrabThrowdelta_corrective_animation.smd" {
        fps 30
}

$animation "LookU" "kolossos_anims\LookU.smd" {
        fps 30
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "LookU_corrective_animation" 0
}

$animation "LookD" "kolossos_anims\LookD.smd" {
        fps 30
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "LookD_corrective_animation" 0
}

$animation "LookC" "kolossos_anims\LookC.smd" {
        fps 30
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "LookC_corrective_animation" 0
}

$animation "LookR" "kolossos_anims\LookR.smd" {
        fps 30
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "LookR_corrective_animation" 0
}

$animation "LookL" "kolossos_anims\LookL.smd" {
        fps 30
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "LookL_corrective_animation" 0
}

$animation "swingdelta" "kolossos_anims\swingdelta.smd" {
        fps 60
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "swingdelta_corrective_animation" 0
        weightlist "weights_swingdeltatosequence"
}

$animation "Grabdelta" "kolossos_anims\Grabdelta.smd" {
        fps 60
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "Grabdelta_corrective_animation" 0
        weightlist "weights_swingdeltatosequence"
}

$animation "GrabIdledelta" "kolossos_anims\GrabIdledelta.smd" {
        fps 60
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "GrabIdledelta_corrective_animation" 0
        weightlist "weights_swingdeltatosequence"
}

$animation "GrabPunchdelta" "kolossos_anims\GrabPunchdelta.smd" {
        fps 60
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "GrabPunchdelta_corrective_animation" 0
        weightlist "weights_swingdeltatosequence"
}

$animation "GrabThrowdelta" "kolossos_anims\GrabThrowdelta.smd" {
        fps 60
        // Crowbar writes this subtract option to prevent jigglebone and poseparameter problems when delta sequences are recompiled.
        subtract "GrabThrowdelta_corrective_animation" 0
        weightlist "weights_swingdeltatosequence"
}

$sequence "ref" {
        "kolossos_anims\ref.smd"
        fadein 0.2
        fadeout 0.2
        fps 30
        loop
}

$sequence "aim_yaw" {
        "LookR"
        "LookC"
        "LookL"
        autoplay
        blend "aim_yaw" -90 90
        blendwidth 3
        delta
        fadein 0.2
        fadeout 0.2
}

$sequence "aim_pitch" {
        "LookU"
        "LookC"
        "LookD"
        autoplay
        blend "aim_pitch" -90 90
        blendwidth 3
        delta
        fadein 0.2
        fadeout 0.2
}

$sequence "swingsub" {
        "kolossos_anims\swingsub.smd"
        fadein 0.2
        fadeout 0.2
        fps 30
}

$sequence "swingdeltatosequence" {
        "swingdelta"
        delta
        fadein 0.2
        fadeout 0.2
}

$sequence "swing" {
        "kolossos_anims\swing.smd"
        activity "ACT_MELEE_ATTACK_SWING_GESTURE" 1
        { event 1100 13 "Attack" }
        fadein 0.2
        fadeout 0.2
        addlayer "swingdeltatosequence"
        fps 60
        weightlist "weights_swing"
}

$sequence "Kill" {
        "kolossos_anims\Kill.smd"
        { event 1100 8 "Kill_stab" }
        { event 1100 51 "kill_grab" }
        { event 1100 56 "kill_pull" }
        { event 1100 96 "kill_rip" }
        { event 1100 100 "kill_ripfull" }
        { event 1100 169 "kill_throw1" }
        { event 1100 216 "kill_throw2" }
        { event 1100 248 "Step" }
        { event 1100 261 "Step" }
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "idle" {
        "kolossos_anims\idle.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "walk" {
        "kolossos_anims\walk.smd"
        { event 1100 10 "Step" }
        { event 1100 60 "Step" }
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "run" {
        "kolossos_anims\run.smd"
        { event 1100 8 "Step" }
        { event 1100 31 "Step" }
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "Jump" {
        "kolossos_anims\Jump.smd"
        fadein 0.9
        fadeout 0.9
        fps 60
        loop
}

$sequence "Fall" {
        "kolossos_anims\Fall.smd"
        fadein 0.4
        fadeout 0.4
        fps 60
        loop
}

$sequence "climb" {
        "kolossos_anims\climb.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "stun" {
        "kolossos_anims\stun.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "StunStart" {
        "kolossos_anims\StunStart.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "BlockStart" {
        "kolossos_anims\BlockStart.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "BlackCounterMelee" {
        "kolossos_anims\BlackCounterMelee.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "BlockProjectile" {
        "kolossos_anims\BlockProjectile.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "BlockPos" {
        "kolossos_anims\BlockPos.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "SlamInWall" {
        "kolossos_anims\SlamInWall.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "Charge_impaled" {
        "kolossos_anims\Charge_impaled.smd"
        { event 1100 5 "Step" }
        { event 1100 21 "Step" }
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "Charge_notimpaled" {
        "kolossos_anims\Charge_notimpaled.smd"
        { event 1100 5 "Step" }
        { event 1100 21 "Step" }
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "ChargeStart" {
        "kolossos_anims\ChargeStart.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "grabdeltatosequence" {
        "Grabdelta"
        delta
        fadein 0.2
        fadeout 0.2
}

$sequence "Grab" {
        "kolossos_anims\Grab.smd"
        activity "ACT_GESTURE_MELEE_ATTACK1" 1
        fadein 0.2
        fadeout 0.2
        addlayer "grabdeltatosequence"
        fps 60
        weightlist "weights_swing"
}

$sequence "grabidledeltatosequence" {
        "GrabIdledelta"
        delta
        fadein 0.2
        fadeout 0.2
}

$sequence "GrabIdle" {
        "kolossos_anims\GrabIdle.smd"
        activity "ACT_HOVER" 1
        fadein 0.2
        fadeout 0.2
        addlayer "grabidledeltatosequence"
        fps 60
        weightlist "weights_swing"
}

$sequence "GrabPunchdeltaseq" {
        "GrabPunchdelta"
        delta
        fadein 0.2
        fadeout 0.2
}

$sequence "GrabPunch" {
        "kolossos_anims\GrabPunch.smd"
        activity "ACT_GESTURE_MELEE_ATTACK2" 1
        fadein 0.2
        fadeout 0.2
        addlayer "GrabPunchdeltaseq"
        fps 60
        weightlist "weights_swing"
}

$sequence "GrabThrowdeltaseq" {
        "GrabThrowdelta"
        delta
        fadein 0.2
        fadeout 0.2
}

$sequence "GrabThrow" {
        "kolossos_anims\GrabThrow.smd"
        activity "ACT_DISARM" 1
        fadein 0.2
        fadeout 0.2
        addlayer "GrabThrowdeltaseq"
        fps 60
        weightlist "weights_swing"
}


// ---------------------------------------------------------------------------
// v1.5 — LA SERIE FUSIONADA: piernas de la locomocion + brazos del grab
// en UNA secuencia (L4D2 no networka m_AnimOverlay en props: la via real
// del port son secuencias compuestas; generadas por fusion_smd_kolossos.py)
// ---------------------------------------------------------------------------

$sequence "idle_hold" {
        "kolossos_anims\idle_hold.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "walk_hold" {
        "kolossos_anims\walk_hold.smd"
        { event 1100 10 "Step" }
        { event 1100 60 "Step" }
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "run_hold" {
        "kolossos_anims\run_hold.smd"
        { event 1100 8 "Step" }
        { event 1100 31 "Step" }
        fadein 0.2
        fadeout 0.2
        fps 60
        loop
}

$sequence "idle_reach" {
        "kolossos_anims\idle_reach.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "walk_reach" {
        "kolossos_anims\walk_reach.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "run_reach" {
        "kolossos_anims\run_reach.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "idle_punch" {
        "kolossos_anims\idle_punch.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "walk_punch" {
        "kolossos_anims\walk_punch.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "run_punch" {
        "kolossos_anims\run_punch.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "idle_throw" {
        "kolossos_anims\idle_throw.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "walk_throw" {
        "kolossos_anims\walk_throw.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "run_throw" {
        "kolossos_anims\run_throw.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}


// ---------------------------------------------------------------------------
// v2.0 — LA FUSION DEL SWING: el M1 basico (ACT_MELEE_ATTACK_SWING_GESTURE
// del Lua l.2638) con las piernas de la locomocion. Brazos+UpperTorso+Head
// de swingsub.smd (el swing COMPLETO: brazos == swing.smd a 0.0 grados +
// el delta del addlayer ya aplicado), Root+LowerTorso+piernas de la loco.
// Generadas por fusion_swing_kolossos.py — 23 frames @ 60fps = 0.383s
// ---------------------------------------------------------------------------

$sequence "idle_swing" {
        "kolossos_anims\idle_swing.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "walk_swing" {
        "kolossos_anims\walk_swing.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "run_swing" {
        "kolossos_anims\run_swing.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$collisionjoints "kolossos_physics.smd"
{
        $mass 70
        $inertia 10
        $damping 0.2
        $rotdamping 0.1
        $rootbone "Root"


        $jointconstrain "LeftUpperLeg" x limit -70 70 0
        $jointconstrain "LeftUpperLeg" y limit -70 70 0
        $jointconstrain "LeftUpperLeg" z limit -70 70 0

        $jointconstrain "LeftLowerLeg" x limit -70 70 0
        $jointconstrain "LeftLowerLeg" y limit -70 70 0
        $jointconstrain "LeftLowerLeg" z limit -70 70 0

        $jointconstrain "RightUpperLeg" x limit -70 70 0
        $jointconstrain "RightUpperLeg" y limit -70 70 0
        $jointconstrain "RightUpperLeg" z limit -70 70 0

        $jointconstrain "RightLowerLeg" x limit -70 70 0
        $jointconstrain "RightLowerLeg" y limit -70 70 0
        $jointconstrain "RightLowerLeg" z limit -70 70 0

        $jointconstrain "RightFoot" x limit -70 70 0
        $jointconstrain "RightFoot" y limit -70 70 0
        $jointconstrain "RightFoot" z limit -70 70 0

        $jointconstrain "UpperTorso" x limit 0 0 0
        $jointconstrain "UpperTorso" y limit 0 0 0
        $jointconstrain "UpperTorso" z limit 0 0 0

        $jointconstrain "LeftUpperArm" x limit -70 70 0
        $jointconstrain "LeftUpperArm" y limit -70 70 0
        $jointconstrain "LeftUpperArm" z limit -70 70 0

        $jointconstrain "LeftLowerArm" x limit -70 70 0
        $jointconstrain "LeftLowerArm" y limit -70 70 0
        $jointconstrain "LeftLowerArm" z limit -70 70 0

        $jointconstrain "RightUpperArm" x limit -70 70 0
        $jointconstrain "RightUpperArm" y limit -70 70 0
        $jointconstrain "RightUpperArm" z limit -70 70 0

        $jointconstrain "RightLowerArm" x limit -70 70 0
        $jointconstrain "RightLowerArm" y limit -70 70 0
        $jointconstrain "RightLowerArm" z limit -70 70 0

        $jointconstrain "RightHand" x limit -70 70 0
        $jointconstrain "RightHand" y limit -70 70 0
        $jointconstrain "RightHand" z limit -70 70 0

        $jointconstrain "Head" x limit -70 70 0
        $jointconstrain "Head" y limit -70 70 0
        $jointconstrain "Head" z limit -70 70 0

        $jointconstrain "LeftHand" x limit -70 70 0
        $jointconstrain "LeftHand" y limit -70 70 0
        $jointconstrain "LeftHand" z limit -70 70 0

        $jointconstrain "LeftFoot" x limit -70 70 0
        $jointconstrain "LeftFoot" y limit -70 70 0
        $jointconstrain "LeftFoot" z limit -70 70 0
}
