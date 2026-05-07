import java.net.URL;
import java.net.MalformedURLException;

public class HardcodedUrlExample {

    public URL directLiteral() throws MalformedURLException {
        return new URL("https://example.com/direct");
    }

    public URL viaLocalVariable() throws MalformedURLException {
        String spec = "https://example.com/via-local";
        return new URL(spec);
    }

    public URL viaConcatenation() throws MalformedURLException {
        String prefix = "https://example.com";
        String path = "/via-concat";
        return new URL(prefix + path);
    }

    public URL viaReassignment() throws MalformedURLException {
        String spec = "https://example.com/initial";
        spec = "https://example.com/reassigned";
        return new URL(spec);
    }

    private static final String CONSTANT_URL = "https://example.com/constant";

    public URL fromStaticField() throws MalformedURLException {
        return new URL(CONSTANT_URL);
    }

    public URL fromParameter(String userProvided) throws MalformedURLException {
        return new URL(userProvided);
    }

    public URL getenvDirect() throws MalformedURLException {
        return new URL(System.getenv("SERVICE_URL"));
    }

    public URL getenvViaLocal() throws MalformedURLException {
        String spec = System.getenv("SERVICE_URL");
        return new URL(spec);
    }

    public URL getenvViaConcat() throws MalformedURLException {
        String host = System.getenv("SERVICE_HOST");
        return new URL("https://" + host + "/api");
    }

    private String readEndpoint() {
        return System.getenv("SERVICE_URL");
    }

    public URL getenvAcrossMethods() throws MalformedURLException {
        String spec = readEndpoint();
        return new URL(spec);
    }

    private String endpoint = System.getenv("SERVICE_URL");

    public URL getenvViaField() throws MalformedURLException {
        return new URL(this.endpoint);
    }

    public URL buildUrl(String spec) throws MalformedURLException {
        return new URL(spec);
    }

    public URL getenvThroughHelper() throws MalformedURLException {
        return buildUrl(System.getenv("SERVICE_URL"));
    }
}
