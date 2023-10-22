import rpcHealthCheck from "./healthcheck";
import {
    bAuthenticationCustom,
} from "./authentication";

import {
    matchInit,
    matchJoin,
    matchJoinAttempt,
    matchLeave,
    matchLoop,
    matchSignal,
    matchTerminate,
    matchCreate
} from "./matchhandler";

import {
    bPartyJoin 
} from "./realtime";

function InitModule(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, initializer: nkruntime.Initializer) {
    initializer.registerRpc("Heathcheck", rpcHealthCheck);
    initializer.registerRpc("CreateMatch", matchCreate);
    initializer.registerMatch("lobby", {
        matchInit,
        matchJoinAttempt,
        matchJoin,
        matchLeave,
        matchLoop,
        matchSignal,
        matchTerminate,
    });
    initializer.registerBeforeAuthenticateCustom(bAuthenticationCustom);
    initializer.registerRtBefore("PartyJoin", bPartyJoin);
    logger.info("Javascript module loaded");
}

// Reference InitModule to avoid it getting removed on build
!InitModule && InitModule.bind(null);