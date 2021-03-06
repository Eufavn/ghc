-- -----------------------------------------------------------------------------
--
-- (c) The University of Glasgow, 2011
--
-- Generate code to initialise cost centres
--
-- -----------------------------------------------------------------------------

module ProfInit (profilingInitCode) where

import CLabel
import CostCentre
import Outputable
import Platform
import StaticFlags
import FastString
import Module

-- -----------------------------------------------------------------------------
-- Initialising cost centres

-- We must produce declarations for the cost-centres defined in this
-- module;

profilingInitCode :: Platform -> Module -> CollectedCCs -> SDoc
profilingInitCode platform this_mod (local_CCs, ___extern_CCs, singleton_CCSs)
 | not opt_SccProfilingOn = empty
 | otherwise
 = vcat
    [ text "static void prof_init_" <> ppr this_mod
         <> text "(void) __attribute__((constructor));"
    , text "static void prof_init_" <> ppr this_mod <> text "(void)"
    , braces (vcat (
         map emitRegisterCC           local_CCs ++
         map emitRegisterCCS          singleton_CCSs
       ))
    ]
 where
   emitRegisterCC cc   =
      ptext (sLit "extern CostCentre ") <> cc_lbl <> ptext (sLit "[];") $$
      ptext (sLit "REGISTER_CC(") <> cc_lbl <> char ')' <> semi
     where cc_lbl = pprPlatform platform (mkCCLabel cc)
   emitRegisterCCS ccs =
      ptext (sLit "extern CostCentreStack ") <> ccs_lbl <> ptext (sLit "[];") $$
      ptext (sLit "REGISTER_CCS(") <> ccs_lbl <> char ')' <> semi
     where ccs_lbl = pprPlatform platform (mkCCSLabel ccs)
