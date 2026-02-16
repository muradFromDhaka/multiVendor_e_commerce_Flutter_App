 package com.abc.SpringSecurityExample.service;

 import jakarta.annotation.PostConstruct;
 import org.springframework.beans.factory.annotation.Value;
 import org.springframework.stereotype.Service;
 import org.springframework.web.multipart.MultipartFile;

 import java.io.IOException;
 import java.nio.file.Files;
 import java.nio.file.Path;
 import java.nio.file.Paths;
 import java.nio.file.StandardCopyOption;
 import java.util.UUID;

 @Service
 public class FileStorageService {

     @Value("${file.upload-dir}")
     private String uploadDir;

     private Path uploadPath;

     @PostConstruct
     public void init() throws IOException {
         uploadPath = Paths.get(uploadDir);

         if (!Files.exists(uploadPath)) {
             Files.createDirectories(uploadPath);
         }
     }


     public String saveFile(MultipartFile file) throws IOException{
         String fileName = UUID.randomUUID() + "-" + file.getOriginalFilename();
         Path targetPath = uploadPath.resolve(fileName);
         Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

         // Windows backslash problem fix
         String dbPath = targetPath.toString().replace("\\", "/");
         return dbPath;
     }


     public void deleteFile(String fileName) throws IOException{
         Files.deleteIfExists(uploadPath.resolve(fileName));
     }

 }
