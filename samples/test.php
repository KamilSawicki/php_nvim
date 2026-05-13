<?php

declare(strict_types=1);

namespace App\Domain;

use DateTime;
use InvalidArgumentException;

const VERSION = '1.0.0';

interface Describable
{
    public function describe(): string;
}

abstract class Animal implements Describable
{
    protected string $name;
    protected int $age;

    public function __construct(string $name, int $age)
    {
        if ($age < 0) {
            throw new InvalidArgumentException("Age cannot be negative: $age");
        }

        $this->name = $name;
        $this->age  = $age;
    }

    abstract public function speak(): string;

    public function describe(): string
    {
        return sprintf('%s is %d years old and says: "%s"', $this->name, $this->age, $this->speak());
    }

    public function getAge(): int
    {
        return $this->age;
    }
}

class Dog extends Animal
{
    private array $tricks = [];

    public function __construct(string $name, int $age, string ...$tricks)
    {
        parent::__construct($name, $age);
        $this->tricks = $tricks;
    }

    public function speak(): string
    {
        return 'Woof!';
    }

    public function learn(string $trick): void
    {
        $this->tricks[] = $trick;
    }

    public function getTricks(): array
    {
        return $this->tricks;
    }
}

enum Status: string
{
    case Active   = 'active';
    case Inactive = 'inactive';
    case Pending  = 'pending';

    public function label(): string
    {
        return match($this) {
            Status::Active   => 'Active',
            Status::Inactive => 'Inactive',
            Status::Pending  => 'Pending',
        };
    }
}

readonly class UserDto
{
    public function __construct(
        public int $id,
        public string $name,
        public string $email,
        public Status $status = Status::Active,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            id:     (int)   $data['id'],
            name:           $data['name'],
            email:          $data['email'],
            status: Status::from($data['status'] ?? 'active'),
        );
    }
}

class UserRepository
{
    private array $store = [];

    public function save(UserDto $user): void
    {
        $this->store[$user->id] = $user;
    }

    public function find(int $id): ?UserDto
    {
        return $this->store[$id] ?? null;
    }

    /** @return UserDto[] */
    public function findAll(): array
    {
        return array_values($this->store);
    }

    public function findActive(): array
    {
        return array_filter(
            $this->findAll(),
            fn(UserDto $u) => $u->status === Status::Active
        );
    }
}

function buildGreeting(string $name, bool $formal = false): string
{
    $prefix = $formal ? 'Good day' : 'Hey';
    return "$prefix, $name!";
}

// --- main ---

$dog = new Dog('Rex', 3, 'sit', 'shake');
$dog->learn('roll over');

echo $dog->describe() . PHP_EOL;
echo 'Tricks: ' . implode(', ', $dog->getTricks()) . PHP_EOL;

$repo = new UserRepository();

foreach ([
    ['id' => 1, 'name' => 'Alice', 'email' => 'alice@example.com', 'status' => 'active'],
    ['id' => 2, 'name' => 'Bob',   'email' => 'bob@example.com',   'status' => 'inactive'],
    ['id' => 3, 'name' => 'Carol', 'email' => 'carol@example.com', 'status' => 'pending'],
] as $data) {
    $repo->save(UserDto::fromArray($data));
}

$active = $repo->findActive();
echo 'Active users: ' . count($active) . PHP_EOL;

$user = $repo->find(1);
if ($user !== null) {
    echo buildGreeting($user->name, formal: true) . PHP_EOL;
    echo 'Status: ' . $user->status->label() . PHP_EOL;
}

$numbers  = range(1, 10);
$evens    = array_filter($numbers, fn(int $n) => $n % 2 === 0);
$doubled  = array_map(fn(int $n) => $n * 2, $evens);
$sum      = array_reduce($doubled, fn(int $carry, int $n) => $carry + $n, 0);

echo "Sum of doubled evens: $sum" . PHP_EOL;
