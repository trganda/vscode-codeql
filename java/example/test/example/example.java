import org.springframework.web.bind.annotation.*;
import org.springframework.stereotype.Controller;
import org.springframework.http.ResponseEntity;

// Test case for Spring MVC REST API mappings
@Controller
@RequestMapping("/api/users")
public class example {
    
    @RequestMapping(value = "/getuser", method = org.springframework.web.bind.annotation.RequestMethod.GET)
    public ResponseEntity<String> getUser() {
        return ResponseEntity.ok("Get user");
    }
    
    @RequestMapping(value = "/create", method = org.springframework.web.bind.annotation.RequestMethod.POST)
    public ResponseEntity<String> createUser() {
        return ResponseEntity.ok("User created");
    }
    
    @RequestMapping(value = "/update", method = org.springframework.web.bind.annotation.RequestMethod.PUT)
    public ResponseEntity<String> updateUser() {
        return ResponseEntity.ok("User updated");
    }
    
    @RequestMapping(value = "/delete", method = org.springframework.web.bind.annotation.RequestMethod.DELETE)
    public ResponseEntity<String> deleteUser() {
        return ResponseEntity.ok("User deleted");
    }
    
    @RequestMapping(value = "/list", method = org.springframework.web.bind.annotation.RequestMethod.GET)
    public ResponseEntity<String> listUsers() {
        return ResponseEntity.ok("List of users");
    }
}

@Controller
@RequestMapping("/api/products")
class ProductController {
    
    @RequestMapping(value = "/detail", method = org.springframework.web.bind.annotation.RequestMethod.GET)
    public String getProduct() {
        return "Product detail";
    }
    
    @RequestMapping(value = "/search", method = org.springframework.web.bind.annotation.RequestMethod.POST)
    public String searchProducts() {
        return "Search results";
    }
}

@Controller
@RequestMapping("/api/orders")
class OrderController {
    
    @RequestMapping(value = "/getOrder", method = org.springframework.web.bind.annotation.RequestMethod.GET)
    public String getOrder() {
        return "Order";
    }
    
    @RequestMapping(value = "/createOrder", method = org.springframework.web.bind.annotation.RequestMethod.POST)
    public String createOrder() {
        return "Order created";
    }
}