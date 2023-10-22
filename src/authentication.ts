const bAuthenticationCustom = function(ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, data: any) : any | void {
    logger.info(`Before authentication hook call ${data}`);
}

export {
    bAuthenticationCustom,
};