using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace Bulky.Model
{
    public class Catagory
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [DisplayName("Catagory Name")]
        public string Name { get; set; }
        [DisplayName("Display Order")]
        [Range(1, 100, ErrorMessage = "The number must be between 1-100")]

        public int DisplayOrder { get; set; }
    }
}
