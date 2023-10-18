function rpcHealthCheck(ctx, logger, nk, payload) {
  logger.info("Healthcheck RPC loaded");
  return JSON.stringify({
    healthcheck: "OK"
  });
}

var matchInit = function matchInit(ctx, logger, nk, params) {
  return {
    state: {
      presences: {},
      emptyTicks: 0
    },
    tickRate: 5,
    label: ""
  };
};
var matchJoin = function matchJoin(ctx, logger, nk, dispatcher, tick, state, presences) {
  presences.forEach(function (p, index) {
    state.presences[p.sessionId] = p;
  });
  return {
    state: state
  };
};
var matchLeave = function matchLeave(ctx, logger, nk, dispatcher, tick, state, presences) {
  presences.forEach(function (p, index) {
    delete state.presences[p.sessionId];
  });
  return {
    state: state
  };
};
var matchLoop = function matchLoop(ctx, logger, nk, dispatcher, tick, state, messages) {
  if (state.presences.length === 0) {
    state.emptyTicks++;
  }
  if (state.emptyTicks === 100) {
    return null;
  }
  return {
    state: state
  };
};
var matchJoinAttempt = function matchJoinAttempt(ctx, logger, nk, dispatcher, tick, state, presence, metadata) {
  logger.debug("%q attemptd to to join Lobby match", ctx.userId);
  return {
    state: state,
    accept: true
  };
};
var matchSignal = function matchSignal(ctx, logger, nk, dispatcher, tick, state, data) {
  return {
    state: state
  };
};
var matchTerminate = function matchTerminate(ctx, logger, nk, dispatcher, tick, state, graceSeconds) {
  return {
    state: state
  };
};

function InitModule(ctx, logger, nk, initializer) {
  initializer.registerRpc("heathcheck", rpcHealthCheck);
  initializer.registerMatch("lobby", {
    matchInit: matchInit,
    matchJoinAttempt: matchJoinAttempt,
    matchJoin: matchJoin,
    matchLeave: matchLeave,
    matchLoop: matchLoop,
    matchSignal: matchSignal,
    matchTerminate: matchTerminate
  });
  logger.info("Javascript module loaded");
}
!InitModule && InitModule.bind(null);
