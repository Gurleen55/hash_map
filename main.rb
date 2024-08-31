require "rubocop"

# this class will be used to create the node object
class Node
  attr_accessor :key, :value, :next_node, :previous_node

  def initialize(key, value)
    @key = key
    @value = value
  end
end

# this will be used to create linked list
class LinkedList
  attr_accessor :first_node, :last_node

  def initialize(first_node = nil, last_node = nil)
    @first_node = first_node
    @last_node = last_node
  end

  def append(key, value)
    new_node = Node.new(key, value)
    if first_node.nil?
      @first_node = new_node
      @last_node = new_node
      return
    end

    last_node.next_node = new_node
    new_node.previous_node = last_node
    @last_node = new_node
  end

  def find_node(key)
    current_node = first_node

    while current_node
      return current_node if key == current_node.key

      current_node = current_node.next_node
    end
    nil
  end

  def each_node
    current_node = first_node

    while current_node
      yield current_node
      current_node = current_node.next_node
    end
  end

  def remove(key)
    current_node = first_node

    while current_node
      if current_node.key == key
        if current_node == first_node
          @first_node = current_node.next_node
          @first_node.previous_node = nil if @first_node
          @last_node = nil unless @first_node # Update @last_node if list is now empty
        elsif current_node == last_node
          @last_node = current_node.previous_node
          @last_node.next_node = nil
        else
          current_node.previous_node.next_node = current_node.next_node
          current_node.next_node.previous_node = current_node.previous_node
        end
        break # Assuming we want to remove only the first occurrence
      end

      current_node = current_node.next_node
    end
  end
end

# class that will contain code for hash table
class HashMap
  attr_accessor :keys, :values

  def initialize
    @capacity = 16
    @bucket = Array.new(@capacity) { LinkedList.new }
    @load_factor = 0.75
    @keys = []
    @values = []
  end

  def hash(key)
    hash_code = 0
    prime_number = 31

    key.each_char { |char| hash_code = (prime_number * hash_code) + char.ord }

    hash_code
  end

  def set(key, value)
    grow_buckets_if_needed

    bucket_number = hash(key) % @bucket.size
    node = @bucket[bucket_number].find_node(key)

    if node
      node.value = value
    else
      @bucket[bucket_number].append(key, value)
      @keys << key
    end
    @values << value
  end

  def grow_buckets_if_needed
    return unless needs_resizing?

    resize_buckets
    rehash_and_redistribute
  end

  def needs_resizing?
    @keys.size > @bucket.size * @load_factor
  end

  def resize_buckets
    @capacity *= 2
    @new_bucket = Array.new(@capacity) { LinkedList.new }
  end

  def rehash_and_redistribute
    @bucket.each do |list|
      list.each_node do |node|
        new_bucket_number = hash(node.key) % @new_bucket.size
        @new_bucket[new_bucket_number].append(node.key, node.value)
      end
    end

    @bucket = @new_bucket
  end

  def get(key)
    bucket_number = hash(key) % @capacity
    node = @bucket[bucket_number].find_node(key)
    node ? node.value : nil
  end

  def has?(key)
    bucket_number = hash(key) % @capacity
    node = @bucket[bucket_number].find_node(key)
    !!node
  end

  def remove(key)
    return nil unless @keys.include?(key)

    bucket_number = hash(key) % @capacity
    value = @bucket[bucket_number].find_node(key).value
    @values.delete(value)
    @bucket[bucket_number].remove(key)
    @keys.delete(key)
  end

  def length
    @keys.size
  end

  def clear
    @capacity = 16
    @bucket = Array.new(@capacity) { LinkedList.new }
    @load_factor = 0.75
    @keys = []
  end

  def entries
    entries = []
    @keys.each_with_index { |key, index| entries << [key, @values[index]] }
    entries
  end
end

test = HashMap.new
test.set("apple", "red")
test.set("banana", "yellow")
test.set("carrot", "orange")
test.set("dog", "brown")
test.set("elephant", "gray")
test.set("frog", "green")
test.set("grape", "purple")
test.set("hat", "black")
test.set("ice cream", "white")
test.set("jacket", "blue")
test.set("kite", "pink")
test.set("lion", "golden")
test.set("moon", "silver")

p test.entries
