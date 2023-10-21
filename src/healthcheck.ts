function rpcHealthCheck(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, payload: string) {
    logger.debug("Healthcheck RPC loaded");
    return JSON.stringify({
        healthcheck: "OK",
    });
}

export default rpcHealthCheck;