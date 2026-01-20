package com.taskmanager.taskservice.integration;

import com.taskmanager.taskservice.model.Task;
import com.taskmanager.taskservice.model.TaskStatus;
import com.taskmanager.taskservice.repository.TaskRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.TestPropertySource;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@TestPropertySource(locations = "classpath:application-test.properties")
class TaskIntegrationTest {

    @Autowired
    private TaskRepository taskRepository;

    private Task task;

    @BeforeEach
    void setUp() {
        task = new Task();
        task.setTitle("Integration Test Task");
        task.setDescription("Integration Test Description");
        task.setUserId(1L);
        task.setStatus(TaskStatus.PENDING);
    }

    @Test
    void testSaveAndFindTask() {
        Task saved = taskRepository.save(task);
        assertNotNull(saved.getId());

        Optional<Task> found = taskRepository.findById(saved.getId());
        assertTrue(found.isPresent());
        assertEquals("Integration Test Task", found.get().getTitle());
    }

    @Test
    void testFindByUserId() {
        taskRepository.save(task);
        List<Task> tasks = taskRepository.findByUserId(1L);
        assertFalse(tasks.isEmpty());
        assertEquals(1L, tasks.get(0).getUserId());
    }

    @Test
    void testDeleteTask() {
        Task saved = taskRepository.save(task);
        taskRepository.deleteById(saved.getId());
        Optional<Task> found = taskRepository.findById(saved.getId());
        assertFalse(found.isPresent());
    }
}
