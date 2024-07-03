using Bulky.Model;
using Microsoft.EntityFrameworkCore;

namespace Bulky.DataAccess.Data
{
    public class ApplicationDbContext:DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext>options):base(options)
        {
                    
        }
        public DbSet<Catagory> Catagories { get; set; }
        protected override void OnModelCreating(ModelBuilder modelbuilder)
        {
            modelbuilder.Entity<Catagory>().HasData(
                new Catagory { Id = 1, Name = "Action", DisplayOrder = 1 },
                new Catagory { Id = 2, Name = "Scifi", DisplayOrder = 2 },
                new Catagory { Id = 3, Name = "History", DisplayOrder = 3 }
                );

        }
    }
}
