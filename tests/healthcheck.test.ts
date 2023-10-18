import { createMock } from 'ts-auto-mock';
import { describe, expect, beforeEach, test } from '@jest/globals';
import rpcHealthCheck from "../src/healthcheck";

describe("rpcHealthCheck", function () {
    let mockCtx: any, mockLogger: any, mockNk: any;
    beforeEach(function () {
        mockCtx = createMock<nkruntime.Context>({ userId: "mock-user" });
        mockLogger = createMock<nkruntime.Logger>();
        mockNk = createMock<nkruntime.Nakama>();
    });

    test("Return healthCheck: OK", function () {
        const result = rpcHealthCheck(mockCtx, mockLogger, mockNk, "");

        expect(result).toBe(JSON.stringify({ healthcheck: "OK" }));
    });
});