package com.example.javaservice;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.ResourceAccessException;

@RestController
@CrossOrigin(origins = "*")
public class ConnectivityController {

    @Autowired
    private RestTemplate restTemplate;

    @Value("${node.url:http://node-service:3000}")
    private String nodeUrl;

    @Value("${python.url:http://python-service:5000}")
    private String pythonUrl;

    @GetMapping("/check/{target}")
    public ConnectivityResponse check(@PathVariable String target) {
        String url;
        String targetName;
        if (target.equalsIgnoreCase("node")) {
            url = nodeUrl + "/health";
            targetName = "Node.js";
        } else if (target.equalsIgnoreCase("python")) {
            url = pythonUrl + "/health";
            targetName = "Python";
        } else {
            return new ConnectivityResponse("Not Connected", target, "Unknown service");
        }

        try {
            String response = restTemplate.getForObject(url, String.class);
            if ("Service is running".equals(response)) {
                return new ConnectivityResponse("Connected", targetName, "✅ OK");
            } else {
                return new ConnectivityResponse("Not Connected", targetName, "❌ Unexpected response");
            }
        } catch (ResourceAccessException e) {
            return new ConnectivityResponse("Not Connected", targetName, "❌ Timeout/Unreachable");
        } catch (Exception e) {
            return new ConnectivityResponse("Not Connected", targetName, "❌ Error: " + e.getMessage());
        }
    }

    // Simple DTO class
    static class ConnectivityResponse {
        public String status;
        public String target;
        public String message;
        ConnectivityResponse(String status, String target, String message) {
            this.status = status;
            this.target = target;
            this.message = message;
        }
    }
}