package com.pokedex.platform;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
// import org.springframework.http.HttpMethod;
// import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
// import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

  // @Bean
  // SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
  //     http
  //         .csrf(AbstractHttpConfigurer::disable)
  //         .authorizeHttpRequests(auth -> auth
  //             .requestMatchers(HttpMethod.GET, "/ping").permitAll()
  //             .requestMatchers(HttpMethod.GET, "/actuator/health").permitAll()
  //             .requestMatchers(HttpMethod.GET, "/actuator/info").permitAll()
  //             .anyRequest().authenticated()
  //         )
  //         .httpBasic(Customizer.withDefaults());

  //     return http.build();
  // }

  @Bean
  SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
    http.csrf(csrf -> csrf.disable()).authorizeHttpRequests(auth -> auth.anyRequest().permitAll());
    return http.build();
  }
}
