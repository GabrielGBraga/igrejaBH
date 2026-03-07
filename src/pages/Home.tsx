import { Link } from "react-router-dom";

export default function Home() {
  return (
    <div>
      <h1>Home</h1>
      {/* O Link envolve o botão e atua como uma âncora */}
      <Link to="/signin">
        <button className="mb-10 bg-blue-500">Sign In</button>
      </Link>
      
      <Link to="/signup">
        <button className="mb-10 bg-blue-500">Sign Up</button>
      </Link>
    </div>
  );
}