package com.abc.SpringSecurityExample.security;


import com.abc.SpringSecurityExample.entity.Role;
import com.abc.SpringSecurityExample.entity.User;
import com.abc.SpringSecurityExample.repository.VendorRepository;
import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.security.Key;
import java.util.ArrayList;
import java.util.Date;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class JwtUtil {

    @Value("${app.jwt.secret}")
    private String SECRET_KEY;

    @Value("${app.jwt.expiration}")
    private long EXPIRATION_TIME;


    private final VendorRepository vendorRepository;

    private SecretKey key() {
        return Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
    }

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(SECRET_KEY));
    }


    public String generateToken(String username) {
        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                    .setSigningKey(getSigningKey())
                    .build()
                    .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    public String extractUsername(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }


    public String generateTokenFromUsername(User user) {

        final Claims claims = Jwts.claims().setSubject(user.getUserName());

        // ✅ Roles
        claims.put("roles", user.getRoles().stream()
                .map(Role::getRoleName)
                .collect(Collectors.toList()));

        claims.put("userName", user.getUserName());
        claims.put("email", user.getEmail());

        // ✅ Resolve VendorId from DB
        vendorRepository.findByUserUserName(user.getUserName())
                .ifPresent(vendor -> {
                    claims.put("vendorId", vendor.getId());
                    System.out.println("VendorId added to JWT: " + vendor.getId());
                });

        System.out.println("Generating JWT for user: " + user.getUserName());

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }
}



//package com.abc.SpringSecurityExample.security;
//
//
//import com.abc.SpringSecurityExample.entity.Role;
//import com.abc.SpringSecurityExample.entity.User;
//import io.jsonwebtoken.*;
//import io.jsonwebtoken.io.Decoders;
//import io.jsonwebtoken.security.Keys;
//import lombok.RequiredArgsConstructor;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.beans.factory.annotation.Value;
//import org.springframework.stereotype.Component;
//
//import javax.crypto.SecretKey;
//import java.security.Key;
//import java.util.ArrayList;
//import java.util.Date;
//import java.util.stream.Collectors;
//
//@Component
//public class JwtUtil {
//
//    @Value("${app.jwt.secret}")
//    private String SECRET_KEY;
//
//    @Value("${app.jwt.expiration}")
//    private long EXPIRATION_TIME;
//
//
//
//    private SecretKey key() {
//        return Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
//    }
//
//    private Key getSigningKey() {
//        return Keys.hmacShaKeyFor(Decoders.BASE64.decode(SECRET_KEY));
//    }
//
//
//    public String generateToken(String username) {
//        return Jwts.builder()
//                .setSubject(username)
//                .setIssuedAt(new Date())
//                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
//                .signWith(getSigningKey(), SignatureAlgorithm.HS512)
//                .compact();
//    }
//
//    public boolean validateToken(String token) {
//        try {
//            Jwts.parserBuilder()
//                    .setSigningKey(getSigningKey())
//                    .build()
//                    .parseClaimsJws(token);
//            return true;
//        } catch (JwtException | IllegalArgumentException e) {
//            return false;
//        }
//    }
//
//    public String extractUsername(String token) {
//        return Jwts.parserBuilder()
//                .setSigningKey(getSigningKey())
//                .build()
//                .parseClaimsJws(token)
//                .getBody()
//                .getSubject();
//    }
//
//
//    public String generateTokenFromUsername(User user) {
//
//
//        final Claims claims = Jwts.claims().setSubject(user.getUserName());
//        claims.put("roles", new ArrayList<>(user.getRoles().stream()
//                .map(Role::getRoleName)
//                .collect(Collectors.toList())));
//        claims.put("userName", user.getUserName()!=null?user.getUserName():0);
//        claims.put("email", user.getEmail()!=null?user.getEmail():"");
//
//        return Jwts.builder()
//                .setClaims(claims)
//                .setSubject(user.getUserName())
//                .setIssuedAt(new Date())
//                .setExpiration(new Date((new Date()).getTime() + EXPIRATION_TIME))
//                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
//                .compact();
//    }
//}