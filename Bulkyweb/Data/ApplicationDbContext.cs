using Bulkyweb.Models;
using Microsoft.EntityFrameworkCore;

namespace Bulkyweb.Data
{
    public class ApplicationDbContext:DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext>options):base(options)
        {
                    
        }
        public DbSet<Catagory> Catagories { get; set; }
    }
}
