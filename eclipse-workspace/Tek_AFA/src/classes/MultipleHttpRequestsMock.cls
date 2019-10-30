@isTest
public class MultipleHttpRequestsMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public MultipleHttpRequestsMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
                throw new MultipleHttpRequestsMockException('HTTP callout not supported for test methods');
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
    
    public class MultipleHttpRequestsMockException extends Exception { }
}