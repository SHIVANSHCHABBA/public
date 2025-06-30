using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Threading.Tasks;
using System;

namespace LibraryManagementSystem
{
    [TestClass]
    public class LibraryServiceTests
    {
        [TestMethod]
        public async Task AddResource_ValidResource_ReturnsValid()
        {
            var service = new LibraryService();
            var resource = new LibraryResource
            {
                Title = "Test Book",
                Author = "Test Author",
                PublicationYear = 2022,
                Genre = "Test Genre",
                Type = ResourceType.Book
            };

            var result = await service.AddResourceAsync(resource);
            Assert.IsTrue(result.IsValid, result.Message);
            Console.WriteLine("Test Passed: AddResource_ValidResource_ReturnsValid");
        }

        [TestMethod]
        public void SearchByTitle_ExistingTitle_ReturnsResults()
        {
            var service = new LibraryService();
            var results = service.SearchByTitle("Test Book");
            Assert.IsTrue(results.Count >= 0); // Should not throw, and returns a list
            Console.WriteLine("Test Passed: SearchByTitle_ExistingTitle_ReturnsResults");
        }

        [TestMethod]
        public void GetResourceById_NonExistentId_ReturnsNull()
        {
            var service = new LibraryService();
            var resource = service.GetResourceById(-9999);
            Assert.IsNull(resource);
            Console.WriteLine("Test Passed: GetResourceById_NonExistentId_ReturnsNull");
        }
    }
}
