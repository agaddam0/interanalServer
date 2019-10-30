trigger customAsyncRequest on Async_Request__c (after insert) {
    AsyncRequestRunner.startJob();
}