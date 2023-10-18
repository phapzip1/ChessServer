import rpcHealthCheck from "./healthcheck";
import {
    matchInit,
    matchJoin,
    matchJoinAttempt,
    matchLeave,
    matchLoop,
    matchSignal,
    matchTerminate
} from "./matchhandler";

function InitModule(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, initializer: nkruntime.Initializer) {
    initializer.registerRpc("heathcheck", rpcHealthCheck);
    initializer.registerMatch("lobby", {
        matchInit,
        matchJoinAttempt,
        matchJoin,
        matchLeave,
        matchLoop,
        matchSignal,
        matchTerminate,
    });
    logger.info("Javascript module loaded");
}

// Reference InitModule to avoid it getting removed on build
!InitModule && InitModule.bind(null);