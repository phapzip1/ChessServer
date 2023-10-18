import { createMock } from 'ts-auto-mock';
import { On, method } from 'ts-auto-mock/extension';
import rpcHealthCheck from "../src/healthcheck";
import { describe, expect, beforeEach, test } from '@jest/globals';

describe("rpcHealthCheck", function () {
    let mockCtx: any, mockLogger: any, mockNk: any, mockLoggerError: any, mockNkStorageRead: any, mockNkStorageWrite: any, mockStorageWriteAck: any;
    beforeEach(function () {
        mockCtx = createMock<nkruntime.Context>({ userId: "mock-user" });
        mockLogger = createMock<nkruntime.Logger>();
        mockNk = createMock<nkruntime.Nakama>();
        mockStorageWriteAck = createMock<nkruntime.StorageWriteAck>();

        mockLoggerError = On(mockLogger).get(method(function (mock) {
            return mock.error;
        }));

        mockNkStorageRead = On(mockNk).get(method(function (mock) {
            return mock.storageRead;
        }));

        mockNkStorageWrite = On(mockNk).get(method(function (mock) {
            return mock.storageWrite;
        }));

    });

    test('returns failure if payload is null', function () {
        const payload = null;
        const result = rpcHealthCheck(mockCtx, mockLogger, mockNk, "");
        const expectedError = 'no payload provided';

        expect(result).toBe(JSON.stringify({ healthcheck: "OK" }));
    });
});