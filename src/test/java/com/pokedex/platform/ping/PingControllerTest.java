package com.pokedex.platform.ping;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(PingController.class)
class PingControllerTest {

  @Autowired private MockMvc mockMvc;

  @Test
  void pingReturnsPong() throws Exception {
    var mvcResult =
        mockMvc
            .perform(get("/ping"))
            .andExpect(status().isOk())
            .andExpect(content().string("pong"))
            .andReturn();

    assertEquals(200, mvcResult.getResponse().getStatus(), "GET /ping should return HTTP 200.");
  }
}
