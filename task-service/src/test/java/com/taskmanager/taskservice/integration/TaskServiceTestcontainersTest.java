package com.taskmanager.taskservice.integration;

import com.taskmanager.taskservice.model.Task;
import com.taskmanager.taskservice.model.TaskStatus;
import com.taskmanager.taskservice.repository.TaskRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Disabled;

import static org.junit.jupiter.api.Assertions.*;

@Disabled("Requires Docker environment")
@DataJpaTest
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class TaskServiceTestcontainersTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private TaskRepository taskRepository;

    private Task task;

    @BeforeEach
    void setUp() {
        task = new Task();
        task.setTitle("Testcontainers Test Task");
        task.setDescription("Testing with Testcontainers");
        task.setUserId(1L);
        task.setStatus(TaskStatus.PENDING);
    }

    @Test
    void testSaveAndRetrieveTask() {
        Task saved = taskRepository.save(task);
        assertNotNull(saved.getId());

        Optional<Task> found = taskRepository.findById(saved.getId());
        assertTrue(found.isPresent());
        assertEquals("Testcontainers Test Task", found.get().getTitle());
        assertEquals(TaskStatus.PENDING, found.get().getStatus());
    }

    @Test
    void testFindByUserId() {
        taskRepository.save(task);
        
        Task task2 = new Task();
        task2.setTitle("Another Task");
        task2.setUserId(2L);
        task2.setStatus(TaskStatus.IN_PROGRESS);
        taskRepository.save(task2);

        List<Task> user1Tasks = taskRepository.findByUserId(1L);
        assertEquals(1, user1Tasks.size());
        assertEquals(1L, user1Tasks.get(0).getUserId());
    }

    @Test
    void testFindByUserIdAndStatus() {
        taskRepository.save(task);
        
        Task completedTask = new Task();
        completedTask.setTitle("Completed Task");
        completedTask.setUserId(1L);
        completedTask.setStatus(TaskStatus.COMPLETED);
        taskRepository.save(completedTask);

        List<Task> pendingTasks = taskRepository.findByUserIdAndStatus(1L, TaskStatus.PENDING);
        assertEquals(1, pendingTasks.size());
        assertEquals(TaskStatus.PENDING, pendingTasks.get(0).getStatus());
    }
}
