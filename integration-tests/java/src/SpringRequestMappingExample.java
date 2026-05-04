import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMethod;

// Test case for Spring MVC REST API mappings
@Controller
@RequestMapping("/api/users")
public class SpringRequestMappingExample {
    
    @RequestMapping(value = "/getuser", method = RequestMethod.GET)
    public ResponseEntity<String> getUser() {
        return ResponseEntity.ok("Get user");
    }
    
    @RequestMapping(value = "/create", method = RequestMethod.POST)
    public ResponseEntity<String> createUser() {
        return ResponseEntity.ok("User created");
    }
    
    @RequestMapping(value = "/update", method = RequestMethod.PUT)
    public ResponseEntity<String> updateUser() {
        return ResponseEntity.ok("User updated");
    }
    
    @RequestMapping(value = "/delete", method = RequestMethod.DELETE)
    public ResponseEntity<String> deleteUser() {
        return ResponseEntity.ok("User deleted");
    }
    
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public ResponseEntity<String> listUsers() {
        return ResponseEntity.ok("List of users");
    }
}

@Controller
@RequestMapping("/api/products")
class ProductController {
    
    @RequestMapping(value = "/detail", method = RequestMethod.GET)
    public String getProduct() {
        return "Product detail";
    }
    
    @RequestMapping(value = "/search", method = RequestMethod.POST)
    public String searchProducts() {
        return "Search results";
    }
}

@Controller
@RequestMapping("/api/orders")
class OrderController {
    
    @RequestMapping(value = "/getOrder", method = RequestMethod.GET)
    public String getOrder() {
        return "Order";
    }
    
    @RequestMapping(value = "/createOrder", method = RequestMethod.POST)
    public String createOrder() {
        return "Order created";
    }
}