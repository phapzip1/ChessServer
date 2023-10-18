const rpcHealthCheck = function(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, payload: string) {
    logger.info("Healthcheck RPC loaded");
    return JSON.stringify({
        healthcheck: "OK",
    });
}

export default rpcHealthCheck;