const bPartyJoin = function (ctx: nkruntime.Context, logger: nkruntime.Logger, nk: nkruntime.Nakama, envelope: any): any | void {
    logger.debug(`Join party called ${ctx.userId}`);
    return envelope;
}

export {
    bPartyJoin,
};