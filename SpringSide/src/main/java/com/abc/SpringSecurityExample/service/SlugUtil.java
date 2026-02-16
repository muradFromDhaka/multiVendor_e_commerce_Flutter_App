package com.abc.SpringSecurityExample.service;

public class SlugUtil {

    // Example: "My Shop 123" → "my-shop-123"
    public static String toSlug(String input) {
        if (input == null) return "";
        return input.toLowerCase()
                .trim()
                .replaceAll("[^a-z0-9]+", "-") // non-alphanumeric → hyphen
                .replaceAll("^-|-$", "");      // leading/trailing hyphen
    }
}
